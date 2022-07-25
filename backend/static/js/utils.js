export const tags = ["Relax", "History", "Food", "Shopping", "Religion"];

export const getFilename = path => path.substring(path.lastIndexOf('/') + 1);

// Form Validation
export const nameRegExp = "^[A-Za-z][A-Za-z0-9,.\"'() ]*$"
export const addressRegExp = "^[A-Za-z0-9][A-Za-z0-9,.\"'() ]*$" 
export const tagRegExp = "^[A-Z][A-Za-z]*$"

export const nameRegExpTitle = "Name should start with a letter. Allowed characters: a-z A-Z 0-9 ,.\"'() "
export const addressRegExpTitle = "Name shouldn't start with a symbol. Allowed characters: a-z A-Z 0-9 ,.\"'() "
export const tagRegExpTitle = "Name should start with a capital letter. Allowed characters: a-z A-Z"
