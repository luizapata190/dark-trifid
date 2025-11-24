const API_BASE = '/api';

// Utility function to get query parameters
function getQueryParam(param) {
    const urlParams = new URLSearchParams(window.location.search);
    return urlParams.get(param);
}

// Load event information
async function loadEventInfo() {
    try {
        const response = await fetch(`${API_BASE}/event`);
        const event = await response.json();
        
        document.getElementById('event-info').innerHTML = `
            <h2>${event.title}</h2>
            <p class="lead">${event.description}</p>
            <div class="event-details">
                <div class="detail-item">
                    <span class="icon">📅</span>
                    <span>${event.date}</span>
                </div>
                <div class="detail-item">
                    <span class="icon">📍</span>
                    <span>${event.location}</span>
                </div>
            </div>
        `;
        
        // Update page title
        document.title = event.title;
    } catch (error) {
        console.error('Error loading event info:', error);
    }
}

// Load speakers
async function loadSpeakers(query = '') {
    try {
        const url = query ? `${API_BASE}/speakers?q=${encodeURIComponent(query)}` : `${API_BASE}/speakers`;
        const response = await fetch(url);
        const speakers = await response.json();
        
        const grid = document.getElementById('speakers-grid');
        
        if (speakers.length === 0) {
            grid.innerHTML = '<p style="text-align: center; color: #5f6368;">No se encontraron ponentes.</p>';
            return speakers.length;
        }
        
        grid.innerHTML = speakers.map(speaker => `
            <div class="speaker-card"
                style="background: white; padding: 20px; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.12); text-align: center;">
                <div class="speaker-avatar"
                    style="width: 80px; height: 80px; background-color: #e8f0fe; border-radius: 50%; margin: 0 auto 15px; display: flex; align-items: center; justify-content: center; font-size: 2rem;">
                    👤
                </div>
                <h4 style="margin-bottom: 5px;">${speaker.name}</h4>
                <p style="color: #5f6368; margin-bottom: 10px;">${speaker.role}</p>
                <a href="${speaker.linkedin}" target="_blank"
                    style="color: #1a73e8; text-decoration: none; font-weight: 500;">Ver LinkedIn</a>
            </div>
        `).join('');
        
        return speakers.length;
    } catch (error) {
        console.error('Error loading speakers:', error);
        return 0;
    }
}

// Load schedule
async function loadSchedule(query = '') {
    try {
        const url = query ? `${API_BASE}/schedule?q=${encodeURIComponent(query)}` : `${API_BASE}/schedule`;
        const response = await fetch(url);
        const schedule = await response.json();
        
        const timeline = document.getElementById('schedule-timeline');
        
        if (schedule.length === 0) {
            timeline.innerHTML = '<p style="text-align: center; color: #5f6368;">No se encontraron eventos en la agenda.</p>';
            return schedule.length;
        }
        
        timeline.innerHTML = schedule.map(item => `
            <div class="timeline-item ${item.id === 'lunch' ? 'lunch-break' : ''}">
                <div class="time">${item.time}</div>
                <div class="content">
                    <div class="category-tag ${item.category.toLowerCase().replace('/', '\\/')}">${item.category}</div>
                    <h4>${item.title}</h4>
                    <p class="description">${item.description}</p>
                    
                    ${item.speaker_details ? `
                        <div class="speakers">
                            ${item.speaker_details.map(speaker => `
                                <div class="speaker">
                                    <span class="speaker-name">${speaker.name}</span>
                                    <span class="speaker-role">${speaker.role}</span>
                                    <a href="${speaker.linkedin}" target="_blank" class="linkedin-link">in</a>
                                </div>
                            `).join('')}
                        </div>
                    ` : ''}
                </div>
            </div>
        `).join('');
        
        return schedule.length;
    } catch (error) {
        console.error('Error loading schedule:', error);
        return 0;
    }
}

// Handle search functionality
function setupSearch() {
    const searchForm = document.getElementById('search-form');
    const searchInput = document.getElementById('search-input');
    const clearSearch = document.getElementById('clear-search');
    const clearSearchModal = document.getElementById('clear-search-modal');
    
    // Get initial query from URL
    const initialQuery = getQueryParam('q');
    if (initialQuery) {
        searchInput.value = initialQuery;
        clearSearch.style.display = 'flex';
    }
    
    // Handle form submission
    searchForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        const query = searchInput.value.trim();
        
        if (query) {
            // Update URL without reloading
            const newUrl = new URL(window.location);
            newUrl.searchParams.set('q', query);
            window.history.pushState({}, '', newUrl);
            
            clearSearch.style.display = 'flex';
            
            // Load filtered results
            const speakersCount = await loadSpeakers(query);
            const scheduleCount = await loadSchedule(query);
            
            // Show modal if no results
            if (speakersCount === 0 && scheduleCount === 0) {
                showNoResultsModal();
            }
        }
    });
    
    // Handle clear search
    const handleClearSearch = () => {
        searchInput.value = '';
        clearSearch.style.display = 'none';
        
        // Update URL
        const newUrl = new URL(window.location);
        newUrl.searchParams.delete('q');
        window.history.pushState({}, '', newUrl);
        
        // Reload all data
        loadSpeakers();
        loadSchedule();
        hideNoResultsModal();
    };
    
    clearSearch.addEventListener('click', (e) => {
        e.preventDefault();
        handleClearSearch();
    });
    
    clearSearchModal.addEventListener('click', handleClearSearch);
}

// Modal functionality
function showNoResultsModal() {
    const modal = document.getElementById('noResultsModal');
    modal.style.display = 'block';
}

function hideNoResultsModal() {
    const modal = document.getElementById('noResultsModal');
    modal.style.display = 'none';
}

function setupModal() {
    const modal = document.getElementById('noResultsModal');
    const closeBtn = document.querySelector('.close-button');
    
    closeBtn.onclick = hideNoResultsModal;
    
    window.onclick = function(event) {
        if (event.target == modal) {
            hideNoResultsModal();
        }
    };
}

// Initialize everything when DOM is loaded
document.addEventListener('DOMContentLoaded', async () => {
    setupSearch();
    setupModal();
    
    // Load initial data
    await loadEventInfo();
    
    const query = getQueryParam('q');
    const speakersCount = await loadSpeakers(query);
    const scheduleCount = await loadSchedule(query);
    
    // Show modal if there's a query but no results
    if (query && speakersCount === 0 && scheduleCount === 0) {
        showNoResultsModal();
    }
});
