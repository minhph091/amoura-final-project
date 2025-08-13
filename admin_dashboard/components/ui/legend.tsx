interface LegendProps {
  items?: {
    name: string
    color: string
  }[]
}

export function Legend({ items = [] }: LegendProps) {
  return (
    <div className="flex flex-wrap gap-4 mt-4 justify-center">
      {items.map((item, index) => (
        <div key={index} className="flex items-center gap-2">
          <div className="w-3 h-3 rounded-full" style={{ backgroundColor: item.color }} />
          <span className="text-sm">{item.name}</span>
        </div>
      ))}
    </div>
  )
}
