// TODO: handle missing values in a nicer way
let authToken = localStorage.getItem('authToken')
let expiration = localStorage.getItem('expiration')

let app = Elm.Main.init({
  flags: {
    authToken,
    expiration
  }
}
);

app.ports.persistUserToLocalStorage.subscribe(({ authToken, expiration }) => {
  localStorage.setItem('authToken', authToken);
  localStorage.setItem('expiration', expiration);
})
