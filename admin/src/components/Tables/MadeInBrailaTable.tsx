import { useEffect, useState } from "react";
import TableCard from "../TableCard";
import { IoCreateOutline, IoRemoveCircleOutline } from "react-icons/io5";
import { LoadingSpinner } from "../LoadingSpinner";
import Sortable from "sortablejs";
import { MadeInBraila } from "../../models/MadeInBrailaModel";
import { EditMadeInBrailaForm } from "../Forms/EditMadeInBrailaForm";

interface Props {
  setModalContent: React.Dispatch<React.SetStateAction<JSX.Element>>;
  closeModal: () => void;
}

export const MadeInBrailaTable: React.FC<Props> = ({ setModalContent, closeModal }) => {
  const [isLoading, setLoading] = useState(true);
  const [madeInBraila, setMadeInBraila] = useState<Array<MadeInBraila>>([]);

  useEffect(() => {
    fetch("/api/fetchMadeInBraila")
      .then(response => response.json())
      .then(data => {
        setMadeInBraila(data);
        setLoading(false);
      });

    const list = document.querySelector<HTMLElement>("#madeinbraila-table tbody")!;

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
          items.push(document.querySelectorAll("#madeinbraila-table tbody tr")![i].id);
        }

        await fetch("/api/updateMadeInBrailaIndex", {
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

  const deleteMadeInBraila = (id: string) => {
    if (confirm("Are you sure you want to delete the entry")) {
      fetch("/api/deleteMadeInBraila/" + id, { method: "DELETE" });
      setMadeInBraila(madeInBraila.filter(item => item._id !== id));
    }
  };

  const updateTable = (updatedMadeInBraila: MadeInBraila) => {
    const index = madeInBraila.findIndex(item => item._id === updatedMadeInBraila._id);
    madeInBraila[index] = updatedMadeInBraila;

    setMadeInBraila(madeInBraila);
  };

  return (
    <TableCard title="Fabrica în Brăila" records={madeInBraila.length}>
      <table id="madeinbraila-table" className={`${isLoading && "h-100"}`}>
        <thead>
          <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Tags</th>
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
              {madeInBraila.map((item, index) => {
                return (
                  <tr id={item._id} key={index}>
                    <td>{item._id}</td>
                    <td>{item.name}</td>
                    <td>{item.tags.join(", ")}</td>
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
                              <EditMadeInBrailaForm
                                madeInBraila={item}
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
                          onClick={() => deleteMadeInBraila(item._id)}
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
