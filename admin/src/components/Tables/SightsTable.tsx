import { useEffect, useState } from "react";
import TableCard from "../TableCard";
import { IoCreateOutline, IoRemoveCircleOutline } from "react-icons/io5";
import { Sight } from "../../models/SightModel";
import { LoadingSpinner } from "../LoadingSpinner";
import { EditSightForm } from "../Forms/EditSightForm";
import Sortable from "sortablejs";

interface Props {
  setModalContent: React.Dispatch<React.SetStateAction<JSX.Element>>;
  closeModal: () => void;
}

export const SightsTable: React.FC<Props> = ({ setModalContent, closeModal }) => {
  const [isLoading, setLoading] = useState(true);
  const [sights, setSights] = useState<Array<Sight>>([]);

  useEffect(() => {
    fetch("/api/fetchSights")
      .then(response => response.json())
      .then(data => {
        setSights(data);
        setLoading(false);
      });

    const list = document.querySelector<HTMLElement>("#sights-table tbody")!;

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
          items.push(document.querySelectorAll("#sights-table tbody tr")![i].id);
        }

        await fetch("/api/updateSightIndex", {
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

  const deleteSight = (id: string) => {
    if (confirm("Are you sure you want to delete the entry")) {
      fetch("/api/deleteSight/" + id, { method: "DELETE" });
      setSights(sights.filter(sight => sight._id !== id));
    }
  };

  const updateTable = (updatedSight: Sight) => {
    const index = sights.findIndex(sight => sight._id === updatedSight._id);
    sights[index] = updatedSight;

    setSights(sights);
  };

  return (
    <TableCard title="Sights" records={sights.length}>
      <table id="sights-table" className={`${isLoading && "h-100"}`}>
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
              {sights.map((sight, index) => {
                return (
                  <tr id={sight._id} key={index}>
                    <td>{sight._id}</td>
                    <td>{sight.name}</td>
                    <td>{sight.tags.join(", ")}</td>
                    <td>
                      <a href={sight.external_link} target="_blank">
                        {sight.external_link}
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
                              <EditSightForm
                                sight={sight}
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
                          onClick={() => deleteSight(sight._id)}
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
