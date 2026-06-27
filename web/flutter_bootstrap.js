{{flutter_js}}
{{flutter_build_config}}

const isLocalhost = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1';

_flutter.loader.load({
  serviceWorkerSettings: isLocalhost ? null : {
    serviceWorkerVersion: {{flutter_service_worker_version}},
  },
  onEntrypointLoaded: async function(engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    
    // Smoothly transition and hide splash screen once Flutter has run
    const splash = document.getElementById('splash-screen');
    if (splash) {
      splash.classList.add('hidden');
      setTimeout(function() {
        splash.remove();
      }, 400); // Matches CSS transition duration
    }
    
    await appRunner.runApp();
  }
});
