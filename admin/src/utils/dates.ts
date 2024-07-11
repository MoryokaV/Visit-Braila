export const convert2LocalDate = (iso_date: Date) => {
  const date = new Date(iso_date);
  const localDate = new Date(date.getTime() - date.getTimezoneOffset() * 1000 * 60);

  return localDate.toISOString().slice(0, 16);
};

export const getMinEndDate = (startDate: Date) => {
  const start_date = new Date(startDate);
  const day = 1 * 1000 * 60 * 60 * 24;
  const convertedDate = new Date(start_date.getTime() + day);
  convertedDate.setHours(0, 0, 0, 0);

  return convert2LocalDate(convertedDate);
};

export function isValidDate(d: Date) {
  return d.getTime() && !isNaN(d.getTime());
}
