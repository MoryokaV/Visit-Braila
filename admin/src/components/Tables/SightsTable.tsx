import { useEffect, useState } from "react";
import TableCard from "../TableCard";
import { IoCreateOutline, IoRemoveCircleOutline } from "react-icons/io5";
import { Sight } from "../../models/SightModel";
import { LoadingSpinner } from "../LoadingSpinner";
import { useAuth } from "../../hooks/useAuth";
import { EditSightForm } from "../Forms/EditSightForm";

interface Props {
  setModalContent: React.Dispatch<React.SetStateAction<JSX.Element>>;
  closeModal: () => void;
}

export const SightsTable: React.FC<Props> = ({ setModalContent, closeModal }) => {
  const { user } = useAuth();
  const [isLoading, setLoading] = useState(true);
  const [sights, setSights] = useState<Array<Sight>>([]);

  useEffect(() => {
    fetch("/api/fetchSights?city_id=" + user?.city_id)
      .then(response => response.json())
      .then(data => {
        setSights(data);
        setLoading(false);
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
              {sights.map((sight, index) => {
                return (
                  <tr key={index}>
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
