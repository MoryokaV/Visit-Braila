import { useEffect, useState } from "react";
import TableCard from "../TableCard";
import { IoCreateOutline, IoRemoveCircleOutline } from "react-icons/io5";
import { LoadingSpinner } from "../LoadingSpinner";
import { Hotel } from "../../models/HotelModel";
import { EditHotelForm } from "../Forms/EditHotelForm";

interface Props {
  setModalContent: React.Dispatch<React.SetStateAction<JSX.Element>>;
  closeModal: () => void;
}

export const HotelsTable: React.FC<Props> = ({ setModalContent, closeModal }) => {
  const [isLoading, setLoading] = useState(true);
  const [hotels, setHotels] = useState<Array<Hotel>>([]);

  useEffect(() => {
    fetch("/api/fetchHotels")
      .then(response => response.json())
      .then(data => {
        setHotels(data);
        setLoading(false);
      });
  }, []);

  const deleteHotel = (id: string) => {
    if (confirm("Are you sure you want to delete the entry")) {
      fetch("/api/deleteHotel/" + id, { method: "DELETE" });
      setHotels(hotels.filter(hotel => hotel._id !== id));
    }
  };

  const updateTable = (updatedHotel: Hotel) => {
    const index = hotels.findIndex(hotel => hotel._id === updatedHotel._id);
    hotels[index] = updatedHotel;

    setHotels(hotels);
  };

  return (
    <TableCard title="Accommodation" records={hotels.length}>
      <table className={`${isLoading && "h-100"}`}>
        <thead>
          <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Stars</th>
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
              {hotels.map((hotel, index) => {
                return (
                  <tr key={index}>
                    <td>{hotel._id}</td>
                    <td>{hotel.name}</td>
                    <td className="stars">{"★".repeat(hotel.stars)}</td>
                    <td>{hotel.tags.join(", ")}</td>
                    <td>
                      <a href={hotel.external_link} target="_blank">
                        {hotel.external_link}
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
                              <EditHotelForm
                                hotel={hotel}
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
                          onClick={() => deleteHotel(hotel._id)}
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
