from database.repository import get_all_talks, get_speaker_by_id, get_all_speakers

async def get_filtered_speakers(query: str = None):
    speakers = await get_all_speakers()
    if not query:
        return speakers
    
    query = query.lower()
    filtered_speakers = []
    for speaker in speakers:
        if query in speaker['name'].lower():
            filtered_speakers.append(speaker)
            
    return filtered_speakers

async def get_schedule(query: str = None):
    talks = await get_all_talks()
    filtered_talks = []
    
    query = query.lower() if query else None

    for talk in talks:
        # Enriquecer con detalles de los ponentes
        speaker_details = []
        for speaker_id in talk.get('speakers', []):
            speaker = await get_speaker_by_id(speaker_id)
            if speaker:
                speaker_details.append(speaker)
        
        talk_with_speakers = {**talk, 'speaker_details': speaker_details}

        # Si hay query, filtramos todo (incluido lunch)
        if query:
            match_title = query in talk['title'].lower()
            match_cat = query in talk['category'].lower()
            match_speaker = any(query in s['name'].lower() for s in speaker_details)
            
            if match_title or match_cat or match_speaker:
                filtered_talks.append(talk_with_speakers)
        # Si no hay query, incluimos todo
        else:
            filtered_talks.append(talk_with_speakers)
            
    return filtered_talks
