import { useEffect, useState } from "react";
import TableCard from "../TableCard";
import { IoCreateOutline, IoRemoveCircleOutline } from "react-icons/io5";
import { LoadingSpinner } from "../LoadingSpinner";
import { Restaurant } from "../../models/RestaurantModel";
import { EditRestaurantForm } from "../Forms/EditRestaurantForm";

interface Props {
  setModalContent: React.Dispatch<React.SetStateAction<JSX.Element>>;
  closeModal: () => void;
}

export const RestaurantsTable: React.FC<Props> = ({ setModalContent, closeModal }) => {
  const [isLoading, setLoading] = useState(true);
  const [restaurants, setRestaurants] = useState<Array<Restaurant>>([]);

  useEffect(() => {
    fetch("/api/fetchRestaurants")
      .then(response => response.json())
      .then(data => {
        setRestaurants(data);
        setLoading(false);
      });
  }, []);

  const deleteRestaurant = (id: string) => {
    if (confirm("Are you sure you want to delete the entry")) {
      fetch("/api/deleteRestaurant/" + id, { method: "DELETE" });
      setRestaurants(restaurants.filter(restaurant => restaurant._id !== id));
    }
  };

  const updateTable = (updatedRestaurant: Restaurant) => {
    const index = restaurants.findIndex(
      restaurant => restaurant._id === updatedRestaurant._id,
    );
    restaurants[index] = updatedRestaurant;

    setRestaurants(restaurants);
  };

  return (
    <TableCard title="Restaurants" records={restaurants.length}>
      <table className={`${isLoading && "h-100"}`}>
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
              {restaurants.map((restaurant, index) => {
                return (
                  <tr key={index}>
                    <td>{restaurant._id}</td>
                    <td>{restaurant.name}</td>
                    <td>{restaurant.tags.join(", ")}</td>
                    <td>
                      <a href={restaurant.external_link} target="_blank">
                        {restaurant.external_link}
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
                              <EditRestaurantForm
                                restaurant={restaurant}
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
                          onClick={() => deleteRestaurant(restaurant._id)}
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
