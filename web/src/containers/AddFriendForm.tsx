import React, { useContext, useEffect, useState } from "react";
import firebase from "../firebase"; // Path to your firebase.js file
import UserContext from "../userContext";

const AddFriendForm = ({ selectedDate }: any) => {
  const user = useContext(UserContext);
  const [name, setName] = useState("");
  const [day, setDay] = useState("");
  const [month, setMonth] = useState("");
  const [year, setYear] = useState("");

  useEffect(() => {
    if (selectedDate) {
      setDay(selectedDate.day.toString());
      setMonth(selectedDate.month.toString());
    }
  }, [selectedDate]);

  const handleSubmit = async (event: any) => {
    event.preventDefault();

    try {
      const friendsRef = firebase.database().ref(`users/${user.uid}/friends`);
      const newFriendRef = friendsRef.push();
      await newFriendRef.set({
        name: name,
        year: year,
        month: month,
        day: day,
      });

      // Reset the form fields
      setName("");
      setDay("");
      setMonth("");
      setYear("");
    } catch (error) {
      console.error(error);
    }
  };
  return (
    <div>
      <h2>Add Friend</h2>
      <form onSubmit={handleSubmit}>
        <div>
          <label>
            Name:
            <input
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
            />
          </label>
        </div>
        <div>
          <label>
            Birthdate:
            <select value={day} onChange={(e) => setDay(e.target.value)}>
              <option value="">Day</option>
              {/* Render the options for days */}
              {Array.from({ length: 31 }, (_, i) => i + 1).map((day) => (
                <option key={day} value={day}>
                  {day}
                </option>
              ))}
            </select>
            <select value={month} onChange={(e) => setMonth(e.target.value)}>
              <option value="">Month</option>
              {/* Render the options for months */}
              {Array.from({ length: 12 }, (_, i) => i + 1).map((month) => (
                <option key={month} value={month}>
                  {month}
                </option>
              ))}
            </select>
            <select value={year} onChange={(e) => setYear(e.target.value)}>
              <option value="">Year</option>
              {/* Render the options for years */}
              {Array.from(
                { length: 100 },
                (_, i) => new Date().getFullYear() - i
              ).map((year) => (
                <option key={year} value={year}>
                  {year}
                </option>
              ))}
            </select>
          </label>
        </div>
        <button type="submit">Add Friend</button>
      </form>
    </div>
  );
};

export default AddFriendForm;
