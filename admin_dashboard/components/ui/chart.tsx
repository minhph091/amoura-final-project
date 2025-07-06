"use client"

import * as React from "react"
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from "@/components/ui/tooltip"

interface ChartContainerProps {
  data: any[]
  xAxisKey: string
  series: {
    key: string
    label: string
    color: string
    type?: "line" | "bar" | "pie"
    valueFormatter?: (value: number) => string
    colors?: string[]
  }[]
  valueKey?: string
  children: React.ReactNode
}

export function ChartContainer({ data, xAxisKey, series, valueKey, children }: ChartContainerProps) {
  return React.cloneElement(children as React.ReactElement, {
    data,
    xAxisKey,
    series,
    valueKey,
  })
}

interface ChartProps {
  data: any[]
  xAxisKey: string
  series: {
    key: string
    label: string
    color: string
    type?: "line" | "bar" | "pie"
    valueFormatter?: (value: number) => string
    colors?: string[]
  }[]
  valueKey?: string
}

export function Chart({ data, xAxisKey, series }: ChartProps) {
  return <svg viewBox={`0 0 600 400`}>{childrenWithProps(data, xAxisKey, series)}</svg>
}

const childrenWithProps = (data: any[], xAxisKey: string, series: any[]) => {
  return React.Children.map(React.Children.toArray(Chart.children), (child) => {
    if (React.isValidElement(child)) {
      return React.cloneElement(child as React.ReactElement, { data, xAxisKey, series })
    }
    return child
  })
}

interface ChartTooltipProps {
  children: React.ReactNode
}

export function ChartTooltip({ children }: ChartTooltipProps) {
  return (
    <TooltipProvider>
      <Tooltip>
        <TooltipTrigger asChild>{children}</TooltipTrigger>
        <TooltipContent>
          <ChartTooltipContent />
        </TooltipContent>
      </Tooltip>
    </TooltipProvider>
  )
}

interface ChartTooltipContentProps {
  item?: any
}

export function ChartTooltipContent({ item }: ChartTooltipContentProps) {
  return <div>Tooltip Content</div>
}

interface ChartBarProps {
  data: any[]
  xAxisKey: string
  series: {
    key: string
    label: string
    color: string
  }[]
}

export function ChartBar({ data, xAxisKey, series }: ChartBarProps) {
  const barWidth = 30
  const xOffset = 20

  return (
    <>
      {data.map((item, index) => (
        <rect
          key={index}
          x={index * (barWidth + xOffset) + 50}
          y={200 - item[series[0].key]}
          width={barWidth}
          height={item[series[0].key]}
          fill={series[0].color}
        />
      ))}
    </>
  )
}

interface ChartXAxisProps {
  data: any[]
  xAxisKey: string
}

export function ChartXAxis({ data, xAxisKey }: ChartXAxisProps) {
  return (
    <>
      {data.map((item, index) => (
        <text key={index} x={index * 50 + 70} y={220} textAnchor="middle">
          {item[xAxisKey]}
        </text>
      ))}
    </>
  )
}

type ChartYAxisProps = {}

export function ChartYAxis() {
  return (
    <text x={20} y={100}>
      Value
    </text>
  )
}

interface ChartPieProps {
  data: any[]
  series: {
    key: string
    label: string
    color: string
    colors?: string[]
    valueFormatter?: (value: number) => string
  }[]
  valueKey?: string
}

export function ChartPie({ data, series, valueKey }: ChartPieProps) {
  const radius = 100
  const centerX = 300
  const centerY = 200

  let total = 0
  data.forEach((item) => {
    total += item[series[0].key]
  })

  let startAngle = 0

  return (
    <>
      {data.map((item, index) => {
        const sliceAngle = (item[series[0].key] / total) * 2 * Math.PI
        const endAngle = startAngle + sliceAngle

        const midAngle = (startAngle + endAngle) / 2
        const x = centerX + radius * Math.cos(midAngle)
        const y = centerY + radius * Math.sin(midAngle)

        const largeArcFlag = sliceAngle > Math.PI ? 1 : 0

        const x1 = centerX + radius * Math.cos(startAngle)
        const y1 = centerY + radius * Math.sin(startAngle)
        const x2 = centerX + radius * Math.cos(endAngle)
        const y2 = centerY + radius * Math.sin(endAngle)

        const d = `M ${x1} ${y1} A ${radius} ${radius} 0 ${largeArcFlag} 1 ${x2} ${y2} L ${centerX} ${centerY} Z`

        const color = series[0].colors ? series[0].colors![index % series[0].colors!.length] : series[0].color

        startAngle = endAngle

        return <path key={index} d={d} fill={color} />
      })}
    </>
  )
}

type ChartLegendProps = {}

export function ChartLegend() {
  return (
    <div className="flex flex-wrap gap-4 mt-4 justify-center">
      {Chart.series?.map((item, index) => (
        <div key={index} className="flex items-center gap-2">
          <div
            className="w-3 h-3 rounded-full"
            style={{ backgroundColor: item.colors ? item.colors[index % item.colors.length] : item.color }}
          />
          <span className="text-sm">{item.label}</span>
        </div>
      ))}
    </div>
  )
}

interface ChartAreaProps {
  data: any[]
  xAxisKey: string
  series: {
    key: string
    label: string
    color: string
  }[]
}

export function ChartArea({ data, xAxisKey, series }: ChartAreaProps) {
  const points = data.map((item, index) => {
    return `${index * 50 + 70},${200 - item[series[0].key]}`
  })

  points.unshift(`70,200`)
  points.push(`${data.length * 50 + 20},200`)

  return <polygon points={points.join(" ")} fill={series[0].color} opacity={0.3} />
}

interface ChartLineProps {
  data: any[]
  xAxisKey: string
  series: {
    key: string
    label: string
    color: string
  }[]
}

export function ChartLine({ data, xAxisKey, series }: ChartLineProps) {
  const points = data.map((item, index) => {
    return `${index * 50 + 70},${200 - item[series[0].key]}`
  })

  return <polyline points={points.join(" ")} fill="none" stroke={series[0].color} strokeWidth="2" />
}
