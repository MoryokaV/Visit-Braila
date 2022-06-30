/* vanilla js
const fet = async () => {
  const reponse = await fetch("fetchSights")
  const data = await reponse.json();

  const body = document.querySelector('body');
  
  for(let i = 0; i < data.length; i++){
    const h3 = document.createElement('h3')
    h3.innerHTML = data[i].name
    const img = document.createElement('img')
    img.src = data[i].imageUrl

    body.appendChild(h3)
    body.appendChild(img)
  }
}

*/


const fet = async () => {
  const data = await $.getJSON("fetchSights")

  for(let i = 0; i < data.length; i++){
    $("body").append($("<h3></h3>").text(data[i].name))
    $("body").append($("<img></img>").attr("src", data[i].imageUrl))
  }
}

fet();

