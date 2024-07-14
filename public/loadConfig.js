(async () => {
    try {
        const configResponse = await fetch('/config.json');
        window.AppConfig = await configResponse.json();
    } catch (error) {
        console.error('Failed to load app configuration:', error);
    }
})();