'use client'

import * as React from 'react'
import { ChevronDownIcon } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Calendar } from '@/components/ui/calendar'
import { Input } from '@/components/ui/input'
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from '@/components/ui/popover'

export function DateTimePicker({
  value,
  onChange,
}: {
  value: Date
  onChange: (date: Date) => void
}) {
  const [open, setOpen] = React.useState(false)
  
  // Track the last value we sent to prevent circular updates
  const lastSentValueRef = React.useRef<Date | null>(null)
  
  // Helper to extract date and time from a Date object
  const getDateAndTime = React.useCallback((date: Date) => {
    const dateOnly = new Date(date.getFullYear(), date.getMonth(), date.getDate())
    const hours = date.getHours().toString().padStart(2, '0')
    const minutes = date.getMinutes().toString().padStart(2, '0')
    const seconds = date.getSeconds().toString().padStart(2, '0')
    return {
      dateOnly,
      timeString: `${hours}:${minutes}:${seconds}`
    }
  }, [])

  // Initialize state from value prop
  const { dateOnly: initialDate, timeString: initialTime } = getDateAndTime(value)
  const [selectedDate, setSelectedDate] = React.useState<Date | undefined>(initialDate)
  const [timeValue, setTimeValue] = React.useState(initialTime)

  // Combine date and time into a single Date object
  const combineDateAndTime = React.useCallback((date: Date | undefined, time: string): Date | undefined => {
    if (!date) return undefined
    const [hours, minutes, seconds] = time.split(':').map(Number)
    const combined = new Date(date)
    combined.setHours(hours || 0, minutes || 0, seconds || 0, 0)
    return combined
  }, [])

  // Only sync with value prop if it changed externally (not from our onChange)
  React.useEffect(() => {
    // Check if this value change came from us
    if (lastSentValueRef.current && Math.abs(lastSentValueRef.current.getTime() - value.getTime()) < 1000) {
      // This is our own update, ignore it
      return
    }
    
    // Value changed externally (e.g., form reset), sync our state
    const { dateOnly, timeString } = getDateAndTime(value)
    setSelectedDate(dateOnly)
    setTimeValue(timeString)
  }, [value, getDateAndTime])

  // Update form value when date is selected
  const handleDateSelect = (date: Date | undefined) => {
    setSelectedDate(date)
    setOpen(false)
    if (date) {
      const combined = combineDateAndTime(date, timeValue)
      if (combined) {
        lastSentValueRef.current = combined
        onChange(combined)
      }
    }
  }

  // Update form value when time changes
  const handleTimeChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newTime = e.target.value
    setTimeValue(newTime)
    if (selectedDate) {
      const combined = combineDateAndTime(selectedDate, newTime)
      if (combined) {
        lastSentValueRef.current = combined
        onChange(combined)
      }
    }
  }

  return (
    <div className="flex gap-4">
      <div className="flex flex-col gap-3">
        <Popover open={open} onOpenChange={setOpen}>
          <PopoverTrigger asChild>
            <Button
              variant="outline"
              className="w-48 justify-between font-normal"
            >
              {selectedDate ? selectedDate.toLocaleDateString('es-ES') : "Seleccionar fecha"}
              <ChevronDownIcon />
            </Button>
          </PopoverTrigger>
          <PopoverContent className="w-auto overflow-hidden p-0" align="start">
            <Calendar
              mode="single"
              selected={selectedDate}
              captionLayout="dropdown"
              onSelect={handleDateSelect}
            />
          </PopoverContent>
        </Popover>
      </div>
      <div className="flex flex-col gap-3">
        <Input
          type="time"
          step="1"
          value={timeValue}
          onChange={handleTimeChange}
          className="bg-background appearance-none [&::-webkit-calendar-picker-indicator]:hidden [&::-webkit-calendar-picker-indicator]:appearance-none"
        />
      </div>
    </div>
  )
}

