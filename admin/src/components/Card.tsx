interface Props {
  title: string;
  children: React.ReactNode;
}

const Card: React.FC<Props> = ({ title, children }) => {
  return (
    <div className="card shadow-sm">
      <h5 className="card-header">{title}</h5>
      <div className="card-body">{children}</div>
    </div>
  );
};

export default Card;
