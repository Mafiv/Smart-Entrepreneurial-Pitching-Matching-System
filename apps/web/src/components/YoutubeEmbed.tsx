import { ExternalLink, Play } from "lucide-react";
import { Button } from "./ui/button";

export function YoutubeEmbed({ url }: { url: string }) {
	if (!url) return null;

	const getYoutubeVideoId = (url: string) => {
		const regExp =
			/^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*).*/;
		const match = url.match(regExp);
		return match && match[2].length === 11 ? match[2] : null;
	};

	const videoId = getYoutubeVideoId(url);
	if (!videoId) return null;

	return (
		<div className="space-y-3">
			<div className="relative w-full aspect-video rounded-xl overflow-hidden border border-border/50 bg-muted/20 shadow-sm">
				<iframe
					src={`https://www.youtube-nocookie.com/embed/${videoId}?rel=0`}
					title="YouTube pitch video"
					allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
					allowFullScreen
					className="absolute top-0 left-0 w-full h-full border-0"
				/>
			</div>
			<div className="flex justify-end">
				<a href={url} target="_blank" rel="noopener noreferrer">
					<Button variant="outline" size="sm" className="gap-2 shadow-sm">
						<Play className="h-3.5 w-3.5 text-primary" />
						<span className="font-medium">Watch on YouTube</span>
						<ExternalLink className="h-3 w-3 ml-0.5 text-muted-foreground" />
					</Button>
				</a>
			</div>
		</div>
	);
}
