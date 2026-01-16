import { deLocalizeUrl } from '$lib/paraglide/runtime';

export const reroute = (request) => deLocalizeUrl(request.url).pathname;

// Removed manual Service Worker registration as it's handled by SvelteKitPWA plugin
