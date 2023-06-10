import firebase from "firebase/compat/app";
import "firebase/compat/auth";
import "firebase/compat/database";

const firebaseConfig = {
  apiKey: "secret",
  authDomain: "env",
  databaseURL: "env",
  projectId: "env",
  storageBucket: "env",
  messagingSenderId: "secret",
  appId: "secret",
  measurementId: "secret",
};

firebase.initializeApp(firebaseConfig);

export default firebase;
