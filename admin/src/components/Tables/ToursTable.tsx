import { useEffect, useState } from "react";
import TableCard from "../TableCard";
import { IoCreateOutline, IoRemoveCircleOutline } from "react-icons/io5";
import { LoadingSpinner } from "../LoadingSpinner";
import { Tour } from "../../models/TourModel";
import { EditTourForm } from "../Forms/EditTourForm";
import Sortable from "sortablejs";

interface Props {
  setModalContent: React.Dispatch<React.SetStateAction<JSX.Element>>;
  closeModal: () => void;
}

export const ToursTable: React.FC<Props> = ({ setModalContent, closeModal }) => {
  const [isLoading, setLoading] = useState(true);
  const [tours, setTours] = useState<Array<Tour>>([]);

  useEffect(() => {
    fetch("/api/fetchTours")
      .then(response => response.json())
      .then(data => {
        setTours(data);
        setLoading(false);
      });

    const list = document.querySelector<HTMLElement>("#tours-table tbody")!;

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
          items.push(document.querySelectorAll("#tours-table tbody tr")![i].id);
        }

        await fetch("/api/updateTourIndex", {
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

  const deleteTour = (id: string) => {
    if (confirm("Are you sure you want to delete the entry")) {
      fetch("/api/deleteTour/" + id, { method: "DELETE" });
      setTours(tours.filter(tour => tour._id !== id));
    }
  };

  const updateTable = (updatedTour: Tour) => {
    const index = tours.findIndex(tour => tour._id === updatedTour._id);
    tours[index] = updatedTour;

    setTours(tours);
  };

  return (
    <TableCard title="Tours" records={tours.length}>
      <table id="tours-table" className={`${isLoading && "h-100"}`}>
        <thead>
          <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Stages</th>
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
              {tours.map((tour, index) => {
                return (
                  <tr id={tour._id} key={index}>
                    <td>{tour._id}</td>
                    <td>{tour.name}</td>
                    <td>{tour.stages.map(stage => stage.text).join(" - ")}</td>
                    <td>
                      <a href={tour.external_link} target="_blank">
                        {tour.external_link}
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
                              <EditTourForm
                                tour={tour}
                                updateTable={updateTable}
                                closeModal={closeModal}
                              />,
                            )
                          }
                        >
                          <IoCreateOutline className="edit-icon" />
                        </button>
                        <button className="btn-icon" onClick={() => deleteTour(tour._id)}>
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
