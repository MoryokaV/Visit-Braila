export const Modal = ({
  modalRef,
  children,
}: {
  modalRef: React.RefObject<HTMLDivElement>;
  children: React.ReactNode;
}) => {
  return (
    <div ref={modalRef} className="modal fade" id="modal" tabIndex={-1} aria-hidden="true">
      <div className="modal-dialog modal-lg modal-dialog-centered">
        <div className="modal-content">
          <div className="modal-header">
            <h5 className="modal-title">Edit entry</h5>
            <button
              type="button"
              className="btn-close"
              data-bs-dismiss="modal"
              aria-label="Close"
            ></button>
          </div>
          <div className="modal-body">{children}</div>
        </div>
      </div>
    </div>
  );
};
