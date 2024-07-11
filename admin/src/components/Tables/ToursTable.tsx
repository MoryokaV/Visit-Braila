import { useEffect, useState } from "react";
import TableCard from "../TableCard";
import { IoCreateOutline, IoRemoveCircleOutline } from "react-icons/io5";
import { LoadingSpinner } from "../LoadingSpinner";
import { useAuth } from "../../hooks/useAuth";
import { Tour } from "../../models/TourModel";
import { EditTourForm } from "../Forms/EditTourForm";

interface Props {
  setModalContent: React.Dispatch<React.SetStateAction<JSX.Element>>;
  closeModal: () => void;
}

export const ToursTable: React.FC<Props> = ({ setModalContent, closeModal }) => {
  const { user } = useAuth();
  const [isLoading, setLoading] = useState(true);
  const [tours, setTours] = useState<Array<Tour>>([]);

  useEffect(() => {
    fetch("/api/fetchTours?city_id=" + user?.city_id)
      .then(response => response.json())
      .then(data => {
        setTours(data);
        setLoading(false);
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
      <table className={`${isLoading && "h-100"}`}>
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
                  <tr key={index}>
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
