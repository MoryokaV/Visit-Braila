import { useEffect, useState } from "react";
import TableCard from "../TableCard";
import { IoCreateOutline, IoRemoveCircleOutline } from "react-icons/io5";
import { LoadingSpinner } from "../LoadingSpinner";
import Sortable from "sortablejs";
import { Personality } from "../../models/PersonalityModel";
import { EditPersonalityForm } from "../Forms/EditPersonalityForm";

interface Props {
  setModalContent: React.Dispatch<React.SetStateAction<JSX.Element>>;
  closeModal: () => void;
}

export const PersonalitiesTable: React.FC<Props> = ({ setModalContent, closeModal }) => {
  const [isLoading, setLoading] = useState(true);
  const [personalities, setPersonalities] = useState<Array<Personality>>([]);

  useEffect(() => {
    fetch("/api/fetchPersonalities")
      .then(response => response.json())
      .then(data => {
        setPersonalities(data);
        setLoading(false);
      });

    const list = document.querySelector<HTMLElement>("#personalities-table tbody")!;

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
          items.push(document.querySelectorAll("#personalities-table tbody tr")![i].id);
        }

        await fetch("/api/updatePersonalitiesIndex", {
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

  const deletePersonality = (id: string) => {
    if (confirm("Are you sure you want to delete the entry")) {
      fetch("/api/deletePersonality/" + id, { method: "DELETE" });
      setPersonalities(personalities.filter(personality => personality._id !== id));
    }
  };

  const updateTable = (updatedPersonality: Personality) => {
    const index = personalities.findIndex(
      personality => personality._id === updatedPersonality._id,
    );
    personalities[index] = updatedPersonality;

    setPersonalities(personalities);
  };

  return (
    <TableCard title="Personalities" records={personalities.length}>
      <table id="personalities-table" className={`${isLoading && "h-100"}`}>
        <thead>
          <tr>
            <th>ID</th>
            <th>Name</th>
            <th>PDF</th>
            <th>Sight link</th>
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
              {personalities.map((personality, index) => {
                return (
                  <tr id={personality._id} key={index}>
                    <td>{personality._id}</td>
                    <td>{personality.name}</td>
                    <td>
                      <a href={personality.pdf} target="_blank">
                        {window.location.origin + personality.pdf}
                      </a>
                    </td>
                    <td>{personality.sight_link}</td>
                    <td>
                      <div className="group">
                        <button
                          className="btn-icon"
                          data-bs-toggle="modal"
                          data-bs-target="#modal"
                          onClick={() =>
                            setModalContent(
                              <EditPersonalityForm
                                personality={personality}
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
                          onClick={() => deletePersonality(personality._id)}
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
