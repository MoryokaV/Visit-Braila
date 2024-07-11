import { useEffect, useRef, useState } from "react";
import { Modal } from "../components/Modal";
import { SightsTable } from "../components/Tables/SightsTable";
import { ToursTable } from "../components/Tables/ToursTable";
import { RestaurantsTable } from "../components/Tables/RestaurantsTable";
import { HotelsTable } from "../components/Tables/HotelsTable";
import { EventsTable } from "../components/Tables/EventsTable";
import "react-quill/dist/quill.snow.css";

export default function Dashboard() {
  const modalRef = useRef<HTMLDivElement>(null);
  const [modalContent, setModalContent] = useState(<></>);

  const clearModal = () => setModalContent(<></>);

  const closeModal = () => window.bootstrap.Modal.getInstance(modalRef.current!)?.hide();

  useEffect(() => {
    modalRef.current?.addEventListener("hidden.bs.modal", clearModal);

    return () => {
      modalRef.current?.removeEventListener("hidden.bs.modal", clearModal);
    };
  }, []);

  return (
    <>
      <div className="container-fluid p-3">
        <div className="row gy-3 gx-0">
          <SightsTable setModalContent={setModalContent} closeModal={closeModal} />
          <ToursTable setModalContent={setModalContent} closeModal={closeModal} />
          <RestaurantsTable setModalContent={setModalContent} closeModal={closeModal} />
          <HotelsTable setModalContent={setModalContent} closeModal={closeModal} />
          <EventsTable setModalContent={setModalContent} closeModal={closeModal} />
        </div>
      </div>
      <Modal modalRef={modalRef}>{modalContent}</Modal>
    </>
  );
}
