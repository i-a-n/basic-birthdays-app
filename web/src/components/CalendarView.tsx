import * as React from "react";
import { Dayjs } from "dayjs";
import Badge from "@mui/material/Badge";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import {
  LocalizationProvider,
  PickersDay,
  PickersDayProps,
} from "@mui/x-date-pickers";

import { DateCalendar } from "@mui/x-date-pickers/DateCalendar";
import { DayCalendarSkeleton } from "@mui/x-date-pickers/DayCalendarSkeleton";

function isBirthday(date: Dayjs, daysToHighlight: string[]) {
  const day = date.date();
  const month = date.month() + 1;
  const formattedDate = `${month}-${day}`;

  return daysToHighlight.includes(formattedDate);
}

function ServerDay(
  props: PickersDayProps<Dayjs> & { highlightedDays?: string[] }
) {
  const { highlightedDays = [], day, outsideCurrentMonth, ...other } = props;

  const isFriendBirthday = isBirthday(day, highlightedDays);

  return (
    <Badge
      key={day.toString()}
      overlap="circular"
      badgeContent={isFriendBirthday ? "🎉" : undefined}
    >
      <PickersDay
        {...other}
        outsideCurrentMonth={outsideCurrentMonth}
        day={day}
      />
    </Badge>
  );
}

interface CalendarViewProps {
  daysToHighlight: string[];
  isLoading: boolean;
  onDateSelect: (day: number, month: number) => void;
}

const CalendarView: React.FC<CalendarViewProps> = ({
  daysToHighlight,
  isLoading,
  onDateSelect,
}) => {
  const slotProps: {
    day?: { highlightedDays?: string[] };
  } = {
    day: {
      highlightedDays: daysToHighlight,
    },
  };

  const handleMonthChange = (date: Dayjs) => {
    const month = date.month() + 1;

    const filteredDaysToHighlight = daysToHighlight.filter((date) => {
      const [highlightedMonth] = date.split("-");
      return parseInt(highlightedMonth, 10) === month;
    });

    slotProps.day = {
      highlightedDays: filteredDaysToHighlight,
    };
  };

  const handleDateSelect = (date: Dayjs | null) => {
    if (!date) return;
    const day = date.date() || 0;
    const month = date.month() + 1;
    onDateSelect(day, month);
  };

  return (
    <LocalizationProvider dateAdapter={AdapterDayjs}>
      <DateCalendar
        loading={isLoading}
        renderLoading={() => <DayCalendarSkeleton />}
        slots={{
          day: ServerDay,
        }}
        slotProps={slotProps as any}
        onMonthChange={handleMonthChange}
        onChange={handleDateSelect}
      />
    </LocalizationProvider>
  );
};

export default CalendarView;
