import { useEffect, useState } from "react";
import TableCard from "../TableCard";
import { IoCreateOutline, IoRemoveCircleOutline } from "react-icons/io5";
import { Park } from "../../models/ParkModel";
import { LoadingSpinner } from "../LoadingSpinner";
import Sortable from "sortablejs";

interface Props {
  setModalContent: React.Dispatch<React.SetStateAction<JSX.Element>>;
  closeModal: () => void;
}

export const ParksTable: React.FC<Props> = ({ setModalContent, closeModal }) => {
  const [isLoading, setLoading] = useState(true);
  const [parks, setParks] = useState<Array<Park>>([]);

  useEffect(() => {
    fetch("/api/fetchParks")
      .then(response => response.json())
      .then(data => {
        setParks(data);
        setLoading(false);
      });

    const list = document.querySelector<HTMLElement>("#parks-table tbody")!;

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
          items.push(document.querySelectorAll("#parks-table tbody tr")![i].id);
        }

        await fetch("/api/updateParkIndex", {
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

  const deletePark = (id: string) => {
    if (confirm("Are you sure you want to delete the entry")) {
      fetch("/api/deletePark/" + id, { method: "DELETE" });
      setParks(parks.filter(park => park._id !== id));
    }
  };

  const updateTable = (updatedPark: Park) => {
    const index = parks.findIndex(park => park._id === updatedPark._id);
    parks[index] = updatedPark;

    setParks(parks);
  };

  return (
    <TableCard title="Parks" records={parks.length}>
      <table id="parks-table" className={`${isLoading && "h-100"}`}>
        <thead>
          <tr>
            <th>ID</th>
            <th>Name</th>
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
              {parks.map((park, index) => {
                return (
                  <tr id={park._id} key={index}>
                    <td>{park._id}</td>
                    <td>{park.name}</td>
                    <td>
                      <div className="group">
                        <button
                          className="btn-icon"
                          data-bs-toggle="modal"
                          data-bs-target="#modal"
                          onClick={() =>
                            // setModalContent(
                            //   <EditSightForm
                            //     sight={sight}
                            //     updateTable={updateTable}
                            //     closeModal={closeModal}
                            //   />,
                            // )
                            console.log("sdf")
                          }
                        >
                          <IoCreateOutline className="edit-icon" />
                        </button>
                        <button className="btn-icon" onClick={() => deletePark(park._id)}>
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
