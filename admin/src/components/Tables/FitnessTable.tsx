import { useEffect, useState } from "react";
import TableCard from "../TableCard";
import { IoCreateOutline, IoRemoveCircleOutline } from "react-icons/io5";
import { Fitness } from "../../models/FitnessModel";
import { LoadingSpinner } from "../LoadingSpinner";
import Sortable from "sortablejs";
import { EditFitnessForm } from "../Forms/EditFitnessForm";

interface Props {
  setModalContent: React.Dispatch<React.SetStateAction<JSX.Element>>;
  closeModal: () => void;
}

export const FitnessTable: React.FC<Props> = ({ setModalContent, closeModal }) => {
  const [isLoading, setLoading] = useState(true);
  const [fitness, setFitness] = useState<Array<Fitness>>([]);

  useEffect(() => {
    fetch("/api/fetchFitness")
      .then(response => response.json())
      .then(data => {
        setFitness(data);
        setLoading(false);
      });

    const list = document.querySelector<HTMLElement>("#fitness-table tbody")!;

    new Sortable(list, {
      animation: 150,
      easing: "cubic-bezier(0.65, 0, 0.35, 1)",
      delay: 200,
      delayOnTouchOnly: true,
      draggable: "tr",
      onEnd: async function (e) {
        const items: Array<string> = [];

        for (
          let i = Math.min(e.oldIndex!, e.newIndex!);
          i <= Math.max(e.oldIndex!, e.newIndex!);
          i++
        ) {
          items.push(document.querySelectorAll("#fitness-table tbody tr")![i].id);
        }

        await fetch("/api/updateFitnessIndex", {
          method: "PUT",
          body: JSON.stringify({
            oldIndex: e.oldIndex,
            newIndex: e.newIndex,
            items: items,
          }),
          headers: { "Content-Type": "application/json; charset=UTF-8" },
        });
      },
    });
  }, []);

  const deleteFitness = (id: string) => {
    if (confirm("Are you sure you want to delete the entry")) {
      fetch("/api/deleteFitness/" + id, { method: "DELETE" });
      setFitness(fitness.filter(item => item._id !== id));
    }
  };

  const updateTable = (updatedFitness: Fitness) => {
    const index = fitness.findIndex(item => item._id === updatedFitness._id);
    fitness[index] = updatedFitness;

    setFitness(fitness);
  };

  return (
    <TableCard title="Fitness & Wellness" records={fitness.length}>
      <table id="fitness-table" className={`${isLoading && "h-100"}`}>
        <thead>
          <tr>
            <th>ID</th>
            <th>Name</th>
            <th>External link</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {isLoading ? (
            <tr>
              <td colSpan={100} className="my-auto text-center">
                <LoadingSpinner />
              </td>
            </tr>
          ) : (
            <>
              {fitness.map((item, index) => {
                return (
                  <tr id={item._id} key={index}>
                    <td>{item._id}</td>
                    <td>{item.name}</td>
                    <td>
                      <a href={item.external_link} target="_blank">
                        {item.external_link}
                      </a>
                    </td>
                    <td>
                      <div className="group">
                        <button
                          className="btn-icon"
                          data-bs-toggle="modal"
                          data-bs-target="#modal"
                          onClick={() =>
                            setModalContent(
                              <EditFitnessForm
                                fitness={item}
                                updateTable={updateTable}
                                closeModal={closeModal}
                              />,
                            )
                          }
                        >
                          <IoCreateOutline className="edit-icon" />
                        </button>
                        <button
                          className="btn-icon"
                          onClick={() => deleteFitness(item._id)}
                        >
                          <IoRemoveCircleOutline className="edit-icon" />
                        </button>
                      </div>
                    </td>
                  </tr>
                );
              })}
            </>
          )}
        </tbody>
      </table>
    </TableCard>
  );
};
