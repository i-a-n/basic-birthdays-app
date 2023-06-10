import React, { useContext, useEffect, useState } from "react";
import firebase from "../firebase";
import UserContext from "../userContext";
import AddFriendForm from "./AddFriendForm";
import CalendarView from "../components/CalendarView";

type Friend = {
  id?: string;
  name: string;
  year?: string;
  day?: number;
  month?: number;
};

const ViewAndEditBirthdays = () => {
  const user = useContext(UserContext);
  const [friends, setFriends] = useState<Friend[]>([]);
  const [loading, setLoading] = useState<Boolean>(true);

  const [selectedDate, setSelectedDate] = useState<{
    day: number;
    month: number;
  } | null>(null);

  const handleDateSelect = (day: number, month: number) => {
    setSelectedDate({ day, month });
  };

  useEffect(() => {
    const fetchFriends = async () => {
      try {
        const friendsRef = firebase.database().ref(`users/${user.uid}/friends`);
        friendsRef.on("value", (snapshot) => {
          const friendsData: Friend[] = snapshot.val();
          if (friendsData) {
            const friendsList = Object.entries(friendsData).map(
              ([friendId, friendData]) => ({
                id: friendId,
                name: friendData.name,
                day: friendData.day,
                month: friendData.month,
                year: friendData.year,
              })
            );
            setFriends(friendsList);
          }
          setLoading(false);
        });
      } catch (error) {
        console.error(error);
        setLoading(false);
      }
    };

    if (user) {
      fetchFriends();
    }
  }, [user]);

  const handleDeleteFriend = (friendId?: string) => {
    if (!friendId) {
      console.log("no friend id");
      return;
    }
    try {
      const friendRef = firebase
        .database()
        .ref(`users/${user.uid}/friends/${friendId}`);
      friendRef.remove();
    } catch (error) {
      console.error(error);
    }
  };

  if (loading) {
    return <div>Loading...</div>;
  }

  return (
    <div>
      <h2>Friends' Birthdays</h2>
      <AddFriendForm selectedDate={selectedDate} />
      <CalendarView
        daysToHighlight={friends.map(
          (friend) => `${friend.month || 0}-${friend.day || 0}`
        )}
        isLoading={false}
        onDateSelect={handleDateSelect}
      />
      {friends.length > 0 ? (
        <ul>
          {friends.map((friend) => (
            <li key={friend.id}>
              <strong>Name:</strong> {friend.name}, <strong>Birthday:</strong>
              {` ${friend.year || "????"}-${friend.month || "??"}-${
                friend.day || "??"
              }`}
              <button onClick={() => handleDeleteFriend(friend.id)}>
                Delete
              </button>
            </li>
          ))}
        </ul>
      ) : (
        <p>No friends found</p>
      )}
      {selectedDate && (
        <div>
          Selected Date: {selectedDate.day}/{selectedDate.month}
        </div>
      )}
    </div>
  );
};

export default ViewAndEditBirthdays;
