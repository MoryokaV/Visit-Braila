import { useEffect, useState } from "react";
import TableCard from "../TableCard";
import { IoCreateOutline, IoRemoveCircleOutline } from "react-icons/io5";
import { LoadingSpinner } from "../LoadingSpinner";
import { Restaurant } from "../../models/RestaurantModel";
import { EditRestaurantForm } from "../Forms/EditRestaurantForm";
import Sortable from "sortablejs";

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

    const list = document.querySelector<HTMLElement>("#restaurants-table tbody")!;

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
          items.push(document.querySelectorAll("#restaurants-table tbody tr")![i].id);
        }

        await fetch("/api/updateRestaurantIndex", {
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
      <table id="restaurants-table" className={`${isLoading && "h-100"}`}>
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
                  <tr id={restaurant._id} key={index}>
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
