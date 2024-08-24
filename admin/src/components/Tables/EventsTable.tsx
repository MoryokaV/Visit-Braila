import { useEffect, useState } from "react";
import TableCard from "../TableCard";
import { IoCreateOutline, IoRemoveCircleOutline } from "react-icons/io5";
import { LoadingSpinner } from "../LoadingSpinner";
import { Event } from "../../models/EventModel";
import { EditEventForm } from "../Forms/EditEventForm";

interface Props {
  setModalContent: React.Dispatch<React.SetStateAction<JSX.Element>>;
  closeModal: () => void;
}

export const EventsTable: React.FC<Props> = ({ setModalContent, closeModal }) => {
  const [isLoading, setLoading] = useState(true);
  const [events, setEvents] = useState<Array<Event>>([]);

  useEffect(() => {
    fetch("/api/fetchEvents")
      .then(response => response.json())
      .then(data => {
        setEvents(data);
        setLoading(false);
      });
  }, []);

  const deleteEvent = (id: string) => {
    if (confirm("Are you sure you want to delete the entry")) {
      fetch("/api/deleteEvent/" + id, { method: "DELETE" });
      setEvents(events.filter(event => event._id !== id));
    }
  };

  const updateTable = (updatedEvent: Event) => {
    const index = events.findIndex(event => event._id === updatedEvent._id);
    events[index] = updatedEvent;

    setEvents(events);
  };

  return (
    <TableCard title="Events" records={events.length}>
      <table className={`${isLoading && "h-100"}`}>
        <thead>
          <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Date</th>
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
              {events.map((event, index) => {
                const date_time = new Intl.DateTimeFormat("ro-RO", {
                  dateStyle: "short",
                  timeStyle: "short",
                }).format(new Date(event.date_time));

                let end_date_time = undefined;
                if (event.end_date_time) {
                  end_date_time = new Intl.DateTimeFormat("ro-RO", {
                    dateStyle: "short",
                    timeStyle: "short",
                  }).format(new Date(event.end_date_time));
                }

                return (
                  <tr key={index}>
                    <td>{event._id}</td>
                    <td>{event.name}</td>
                    <td>
                      {end_date_time ? date_time + " → " + end_date_time : date_time}
                    </td>
                    <td>
                      <div className="group">
                        <button
                          className="btn-icon"
                          data-bs-toggle="modal"
                          data-bs-target="#modal"
                          onClick={() =>
                            setModalContent(
                              <EditEventForm
                                event={event}
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
                          onClick={() => deleteEvent(event._id)}
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
