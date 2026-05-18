import type * as React from "react";
import { cn } from "@/lib/utils";

interface LogoProps extends React.ComponentProps<"svg"> {
	className?: string;
}

export function Logo({ className, ...props }: LogoProps) {
	return (
		<svg
			xmlns="http://www.w3.org/2000/svg"
			viewBox="0 0 100 100"
			className={cn("h-full w-auto", className)}
			role="img"
			aria-label="SEPMS Logo"
			{...props}
		>
			<title>SEPMS Logo</title>
			{/* Foundation (Investor/Capital) */}
			<rect
				x="43"
				y="28"
				width="44"
				height="44"
				rx="14"
				fill="currentColor"
				className="text-primary"
			/>
			{/* Dynamic Element (Entrepreneur/Idea) with cutout overlap */}
			<circle
				cx="39"
				cy="50"
				r="26"
				fill="currentColor"
				className="text-foreground stroke-background"
				strokeWidth="6"
			/>
		</svg>
	);
}
