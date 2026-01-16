/// <reference lib="webworker" />
declare const self: ServiceWorkerGlobalScope;

// Disabled manual fetch interceptor to avoid conflict with SvelteKit PWA plugin
/*
self.addEventListener('fetch', (event) => {
	// Only handle GET requests
	if (event.request.method !== 'GET') {
		return;
	}

	event.respondWith(
		fetch(event.request.clone())
			.then((response) => {
				// Validate that response is a proper Response object
				if (!response || !(response instanceof Response)) {
					throw new TypeError('Invalid response type');
				}
				return response;
			})
			.catch((error) => {
				// Always return a valid Response object, never undefined or null
				console.error('Fetch error:', error);
				return new Response('Service temporarily unavailable', {
					status: 503,
					statusText: 'Service Unavailable',
					headers: {
						'Content-Type': 'text/plain'
					}
				});
			})
	);
});
*/
