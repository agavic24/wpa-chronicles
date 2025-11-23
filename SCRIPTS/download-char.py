# Use Playwright and BeautifulSoup to extract D&D Beyond character sheet
from playwright.sync_api import sync_playwright
from bs4 import BeautifulSoup
import time
import re
import os
from typing import Dict, List, Any

# URLs of the D&D Beyond character sheets to download
urls = [
    "https://www.dndbeyond.com/characters/144286017",  # Cala
    "https://www.dndbeyond.com/characters/144271085",  # Ra
    "https://www.dndbeyond.com/characters/144272244",  # Aillig
    "https://www.dndbeyond.com/characters/144272508",  # Quinn
    "https://www.dndbeyond.com/characters/141723643",  # Darias
]

# Add your CobaltSession cookie value here
COBALT_SESSION = "eyJhbGciOiJkaXIiLCJlbmMiOiJBMTI4Q0JDLUhTMjU2In0..LK9jA_HvZyDttGLaadoMCg.GbytjfQF9jdC83AaVcpMWtUCtbp2uoU9B67GMJwpzd2QfKuSDfMXVAv_wXepCkjg.OkbKE_cogAxcC7j-zExhsA"
DEBUG_IND = "N"  # Set to "N" for no, "Y" for debugging output

# Set this to an HTML file path to skip downloading and parse from file instead
# Example: USE_LOCAL_FILE = "Cala-raw.html"
USE_LOCAL_FILE = None  # Set to None to download from web
#USE_LOCAL_FILE = "Ra'vek-raw.html"
#USE_LOCAL_FILE = "AilligMcCaird-raw.html"

# Output directory for character sheets
OUTPUT_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "sheets")












def parse_character_data(text: str) -> Dict[str, Any]:
    """Parse the character sheet text into structured data using section headers."""
    lines = text.split('\n')
    
    character = {
        'name': '',
        'basic_info': {},
        'ability_scores': {},
        'skills': [],
        'saving_throws': {},
        'proficiencies': {
            'armor': [],
            'weapons': [],
            'tools': [],
            'languages': []
        },
        'senses': {},
        'combat_stats': {},
        'spells': {
            'spell_attack_bonus': None,
            'spell_save_dc': None,
            'cantrips': [],
            'level_1': [],
            'level_2': [],
            'level_3': [],
            'level_4': [],
            'level_5': [],
            'level_6': [],
            'level_7': [],
            'level_8': [],
            'level_9': []
        },
        'equipment': {
            'weight_carried': None,
            'items': []
        },
        'features_and_traits': {
            'class_features': [],
            'species_traits': [],
            'feats': []
        },
        'actions': {
            'attacks': [],
            'bonus_actions': [],
            'reactions': [],
            'other_actions': []
        },
        'extras': {
            'companions': []
        },
        'raw_sections': {}  # Store raw text from each major section
    }
    
    # Track which section we're currently in
    current_section = None
    section_content = []
    in_proficiencies_section = False  # Track if we're in the Proficiencies and Languages section
    
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        
        # Character name, Gender, Race, Class, Level (only parse once at the beginning)
        if i == 0 and i + 4 < len(lines):
            character['name'] = line
            character['basic_info']['gender'] = lines[i + 1]
            character['basic_info']['race'] = lines[i + 2]
            character['basic_info']['class'] = lines[i + 3]
            character['basic_info']['level'] = lines[i + 4]

        
        # Detect major section headers
        
        if line in ['Actions', 'Spells', 'Inventory', 'Features and Traits', 'Extras']:
            # Only start a new section if we're not already in this section
            # (handles repeated "Inventory" subsection headers)
            if current_section != line:
                # Save previous section if exists
                if current_section and section_content:
                    character['raw_sections'][current_section] = '\n'.join(section_content)
                    section_content = []
                current_section = line
            # If we're already in this section, just add the line to content
            else:
                section_content.append(line)
            i += 1
            continue
        
        # If we're in a section, collect content
        if current_section:
            if line:  # Skip empty lines
                section_content.append(line)
        
        # Parse specific structured data
        # Ability Scores
        if line in ['Strength', 'Dexterity', 'Constitution', 'Intelligence', 'Wisdom', 'Charisma']:
            ability = line
            if i + 4 < len(lines):
                try:
                    # Pattern: Strength / str / + / 0 / 10
                    # i+2 is '+' or '-', i+3 is modifier, i+4 is score
                    sign = lines[i + 2]
                    modifier_val = lines[i + 3]
                    score = lines[i + 4]
                    if score.isdigit() and modifier_val.isdigit():
                        modifier = f"{sign}{modifier_val}"
                        character['ability_scores'][ability] = {
                            'score': int(score),
                            'modifier': modifier
                        }
                except (ValueError, IndexError):
                    pass
        
        # Hit Points
        if line == 'Current' and i + 1 < len(lines):
            try:
                current_hp = lines[i + 1]
                if i + 3 < len(lines) and lines[i + 2] == '/' and i + 4 < len(lines):
                    max_hp = lines[i + 3]
                    if current_hp.isdigit() and max_hp.isdigit():
                        character['combat_stats']['hit_points'] = {
                            'current': int(current_hp),
                            'max': int(max_hp)
                        }
            except (ValueError, IndexError):
                pass
        
        # Armor Class
        if line == 'Armor Class' and i + 2 < len(lines):
            try:
                if lines[i + 1] == 'Armor':
                    character['combat_stats']['armor_class'] = int(lines[i + 2])
            except (ValueError, IndexError):
                pass
        
        # Speed
        if line == 'Walking' and i + 1 < len(lines):
            try:
                speed = lines[i + 1]
                if speed.isdigit():
                    character['combat_stats']['speed'] = int(speed)
            except (ValueError, IndexError):
                pass
        
        # Proficiency Bonus
        if line == 'Proficiency Bonus' and i + 3 < len(lines):
            try:
                if lines[i + 2] == '+':
                    character['combat_stats']['proficiency_bonus'] = int(lines[i + 3])
            except (ValueError, IndexError):
                pass
        
        # Senses
        if 'Passive Perception' in line and i > 0:
            try:
                character['senses']['passive_perception'] = int(lines[i - 1])
            except (ValueError, IndexError):
                pass
        
        if 'Passive Investigation' in line and i > 0:
            try:
                character['senses']['passive_investigation'] = int(lines[i - 1])
            except (ValueError, IndexError):
                pass
        
        if 'Passive Insight' in line and i > 0:
            try:
                character['senses']['passive_insight'] = int(lines[i - 1])
            except (ValueError, IndexError):
                pass
        
        if 'Darkvision' in line:
            character['senses']['darkvision'] = line
        
        # Track when we enter/exit the Proficiencies and Languages section
        if line == 'Proficiencies and Languages':
            in_proficiencies_section = True
        elif line == 'Proficiencies & Training':
            in_proficiencies_section = False
        
        # Proficiencies - collect list items
        # After "Proficiencies and Languages" header, we get subsections
        if line == 'Armor' and in_proficiencies_section and i + 1 < len(lines) and lines[i + 1] not in ['Class']:
            j = i + 1
            while j < len(lines) and lines[j] not in ['Weapons', 'Tools', 'Languages', 'Proficiencies & Training']:
                item = lines[j].strip()
                if item and item != 'Armor':
                    # Remove trailing comma and add to list
                    item = item.rstrip(',').strip()
                    if item:
                        character['proficiencies']['armor'].append(item)
                j += 1
        
        if line == 'Weapons' and in_proficiencies_section and i + 1 < len(lines):
            j = i + 1
            while j < len(lines) and lines[j] not in ['Tools', 'Languages', 'Proficiencies & Training']:
                item = lines[j].strip()
                if item and item != 'Weapons':
                    # Remove trailing comma and add to list
                    item = item.rstrip(',').strip()
                    if item:
                        character['proficiencies']['weapons'].append(item)
                j += 1
        
        if line == 'Tools' and in_proficiencies_section and i + 1 < len(lines):
            j = i + 1
            while j < len(lines) and lines[j] not in ['Languages', 'Proficiencies & Training', 'Skills']:
                item = lines[j].strip()
                if item and item != 'Tools':
                    # Remove trailing comma and add to list
                    item = item.rstrip(',').strip()
                    if item:
                        character['proficiencies']['tools'].append(item)
                j += 1
        
        if line == 'Languages' and in_proficiencies_section and i + 1 < len(lines):
            j = i + 1
            while j < len(lines) and lines[j] not in ['Proficiencies & Training', 'Skills']:
                item = lines[j].strip()
                if item and item != 'Languages':
                    # Remove trailing comma and add to list
                    item = item.rstrip(',').strip()
                    if item:
                        character['proficiencies']['languages'].append(item)
                j += 1
        
        # Saving Throws
        if 'Saving Throw' in line and 'Modifier' not in line and i + 2 < len(lines):
            save_type = line.replace(' Saving Throw', '')
            try:
                if lines[i + 2] == '+' and i + 3 < len(lines):
                    character['saving_throws'][save_type] = f"+{lines[i + 3]}"
                elif lines[i + 2].startswith('+') or lines[i + 2].startswith('-'):
                    character['saving_throws'][save_type] = lines[i + 2]
            except (ValueError, IndexError):
                pass
        
        # Skills - parse the table
        if line == 'Bonus' and i > 0 and lines[i - 1] == 'Skill':
            i += 1
            while i < len(lines):
                if lines[i] in ['DEX', 'WIS', 'INT', 'STR', 'CHA']:
                    ability = lines[i]
                    if i + 1 < len(lines):
                        skill_name = lines[i + 1]
                        if i + 3 < len(lines) and lines[i + 2] == '+':
                            try:
                                bonus = int(lines[i + 3])
                                character['skills'].append({
                                    'name': skill_name,
                                    'ability': ability,
                                    'bonus': bonus
                                })
                                i += 4
                                continue
                            except (ValueError, IndexError):
                                pass
                elif lines[i] in ['Additional Skills', 'Initiative', 'Armor Class']:
                    break
                i += 1
            continue
        
        i += 1
    
    # Save final section
    if current_section and section_content:
        character['raw_sections'][current_section] = '\n'.join(section_content)
    
    # Parse Spells section
    if 'Spells' in character['raw_sections']:
        spell_lines = character['raw_sections']['Spells'].split('\n')
        i = 0
        while i < len(spell_lines):
            line = spell_lines[i]
            
            # Get spell attack bonus and save DC
            if line == 'Spell Attack' and i + 1 < len(spell_lines):
                try:
                    character['spells']['spell_attack_bonus'] = int(spell_lines[i + 1])
                except (ValueError, IndexError):
                    pass
            if line == 'Save DC' and i - 1 >= 0:
                try:
                    character['spells']['spell_save_dc'] = int(spell_lines[i - 1])
                except (ValueError, IndexError):
                    pass
            
            # Parse Cantrips - look for "At Will" followed by spell name
            if line == 'At Will':
                if i + 1 < len(spell_lines):
                    spell_name = spell_lines[i + 1]
                    if spell_name and spell_name not in character['spells']['cantrips']:
                        character['spells']['cantrips'].append(spell_name)
            
            # Parse 1st-9th level spells
            for level_num, level_name in [(1, '1st Level'), (2, '2nd Level'), (3, '3rd Level'), 
                                          (4, '4th Level'), (5, '5th Level'), (6, '6th Level'), 
                                          (7, '7th Level'), (8, '8th Level'), (9, '9th Level')]:
                if line == level_name:
                    spell_key = f'level_{level_num}'
                    j = i + 1
                    # Skip table headers
                    while j < len(spell_lines) and spell_lines[j] in ['Slots', 'Name', 'Time', 'Range', 'Hit / DC', 'Effect', 'Notes', '1', 'st']:
                        j += 1
                    
                    # Collect spell names (they appear before Cast/Use keywords)
                    while j < len(spell_lines):
                        # Stop at next level section
                        next_levels = ['1st Level', '2nd Level', '3rd Level', '4th Level', '5th Level', 
                                      '6th Level', '7th Level', '8th Level', '9th Level']
                        if spell_lines[j] in next_levels:
                            break
                        
                        # If we see Cast or Use, the previous line is a spell name
                        if spell_lines[j] in ['Cast', 'Use']:
                            if j + 1 >= 0:
                                spell_name = spell_lines[j + 1]
                                if spell_name and spell_name not in character['spells'][spell_key] and spell_name not in ['st', '1']:
                                    character['spells'][spell_key].append(spell_name)
                        j += 1
            
            i += 1
    
    # Parse Equipment/Inventory section
    if 'Inventory' in character['raw_sections']:
        inv_lines = character['raw_sections']['Inventory'].split('\n')
        
        i = 0
        while i < len(inv_lines):
            line = inv_lines[i]            
            
            # Look for inventory item markers
            if line == '***INV***':
                # Item name is on the next line
                if i + 1 < len(inv_lines):
                    item_name = inv_lines[i + 1]
                    item_type = inv_lines[i + 2]
                    
                    current_item = {'name': item_name, 'type': item_type}
                    character['equipment']['items'].append(current_item)
            
            i += 1
    
    # Parse Features & Traits section
    if 'Features and Traits' in character['raw_sections']:
        feat_lines = character['raw_sections']['Features and Traits'].split('\n')
        
        current_category = None
        i = 0
        while i < len(feat_lines):
            line = feat_lines[i].strip()
            
            # Detect category headers
            if line == 'Class Features':
                current_category = 'class_features'
            elif line == 'Species Traits':
                current_category = 'species_traits'
            elif line == 'Feats':
                current_category = 'feats'
            
            # Parse Class Features using ***FEATURE*** markers
            if current_category == 'class_features' and line == '***FEATURE***':
                if i + 1 < len(feat_lines):
                    feature_name = feat_lines[i + 1].strip()
                    if feature_name and feature_name not in character['features_and_traits']['class_features']:
                        character['features_and_traits']['class_features'].append(feature_name)
            
            # Parse Species Traits using ***RACIAL*** markers
            elif current_category == 'species_traits' and line == '***RACIAL***':
                # Trait name is on the next line (line 1 after marker)
                if i + 1 < len(feat_lines):
                    trait_name = feat_lines[i + 1].strip()
                    description = feat_lines[i + 4].strip()
                    extra_text = ''  # Initialize extra_text
                    
                    # Special handling for "Ability Score Increases"
                    if trait_name == 'Ability Score Increases':
                        
                        description = feat_lines[i + 5].strip()

                        # Look at lines 6-8 after marker (indices i+6 to i+8) for ability scores
                        ability_scores = []
                        ability_score_names = ['Strength', 'Dexterity', 'Constitution', 'Intelligence', 'Wisdom', 'Charisma']
                        
              
                        for offset in range(5, 9):  # Lines 6-8 after marker
                            if i + offset < len(feat_lines):
                                check_line = feat_lines[i + offset].strip()
                                # Stop if we hit the next section
                                if check_line == '***RACIAL***' or check_line == 'Feats':
                                    break
                                # Check if line contains an ability score name
                                for ability in ability_score_names:
                                    if ability in check_line:
                                        # Extract just the ability name (might be "Intelligence Score")
                                        if ability not in ability_scores:
                                            ability_scores.append(ability)
                                        break
                        
                        # Format: "Description Ability1. Ability2."
                        if ability_scores:
                            extra_text = '. '.join(ability_scores) + '.'
                    
                    else:
                        # loop through lines 5 to 8 and add to extra_text
                        for offset in range(5, 9):  # Lines 6-8 after marker
                            if i + offset < len(feat_lines):
                                check_line = feat_lines[i + offset].strip()
                                # Stop if we hit the next section
                                if check_line == '***RACIAL***' or check_line == 'Feats':
                                    break
                                extra_text += check_line + '.'                        

                    if extra_text:
                        formatted_trait = f"{trait_name}: {description} {extra_text}"
                    else:
                        formatted_trait = f"{trait_name}: {description}"
                                
                    character['features_and_traits']['species_traits'].append(formatted_trait)
            
            # Parse Feats - names appear before source citations
            elif current_category == 'feats':
                # Check if this line is a feat name (followed by a source citation)
                if i + 1 < len(feat_lines):
                    next_line = feat_lines[i + 1].strip()
                    # Source citations typically contain "PHB", "TCoE", etc.
                    if (next_line.startswith('PHB') or next_line.startswith('TCoE') or 
                        next_line.startswith('XGE') or next_line.startswith('TCE') or
                        next_line.startswith('VGM') or next_line.startswith('MTF') or
                        next_line.startswith('FTD') or next_line.startswith('EGW') or
                        next_line.startswith('SCC')):
                        # Only add if it's a reasonable feat name (not too long, not a number, not a section header)
                        if (line and len(line) < 50 and not line.isdigit() and 
                            line not in ['Species Traits', 'Class Features', 'Feats', 'All', 'Artificer Features'] and
                            line not in character['features_and_traits']['feats']):
                            character['features_and_traits']['feats'].append(line)
            
            i += 1
    
    # Parse Actions section
    if 'Actions' in character['raw_sections']:
        action_lines = character['raw_sections']['Actions'].split('\n')
        
        # Parse attacks using ***ATTACK*** markers
        i = 0
        while i < len(action_lines):
            line = action_lines[i]
            
            # Look for attack markers
            if line == '***ATTACK***':
                # Attack name is on the next line
                if i + 1 < len(action_lines):
                    attack_name = action_lines[i + 1]
                    
                    # Attack type is typically 2 lines after the marker
                    attack_type = action_lines[i + 2] if i + 2 < len(action_lines) else ''
                    
                    attack = {
                        'name': attack_name,
                        'type': attack_type,
                        'range': None,
                        'to_hit': None,
                        'damage': None,
                        'properties': []
                    }
                    
                    # Look ahead for range, hit, and damage
                    j = i + 3
                    while j < min(i + 20, len(action_lines)):
                        # Stop at next attack marker
                        if action_lines[j] == '***ATTACK***':
                            break
                        
                        # Range (e.g., "30", "(120)")
                        if action_lines[j].isdigit() and j + 1 < len(action_lines) and action_lines[j + 1].startswith('('):
                            if attack['range'] is None:
                                attack['range'] = f"{action_lines[j]} {action_lines[j + 1]}"
                        
                        # To hit (e.g., "+", "7")
                        if action_lines[j] == '+' and j + 1 < len(action_lines) and action_lines[j + 1].isdigit():
                            if attack['to_hit'] is None:  # First + number is to hit
                                attack['to_hit'] = f"+{action_lines[j + 1]}"
                        
                        # Damage (e.g., "1d6+4")
                        if 'd' in action_lines[j] and any(c.isdigit() for c in action_lines[j]):
                            if attack['damage'] is None:
                                attack['damage'] = action_lines[j]
                        
                        # Properties (comma-separated)
                        if ',' in action_lines[j]:
                            attack['properties'].append(action_lines[j].rstrip(','))
                        
                        j += 1
                    
                    character['actions']['attacks'].append(attack)
                    i = j
                    continue
            
            i += 1
    
    # Parse Extras section
    if 'Extras' in character['raw_sections']:
        extra_lines = character['raw_sections']['Extras'].split('\n')
        
        # Look for companions/pets
        for i, line in enumerate(extra_lines):
            if line == 'Pet':
                # Next non-header lines should be pet data
                j = i + 1
                # Skip table headers
                while j < len(extra_lines) and extra_lines[j] in ['Name', 'AC', 'Hit Points', 'Speed', 'Notes']:
                    j += 1
                
                # Parse pet info
                if j < len(extra_lines):
                    companion = {
                        'name': extra_lines[j] if j < len(extra_lines) else '',
                        'type': extra_lines[j + 2] if j + 2 < len(extra_lines) else '',
                        'ac': None,
                        'hp_current': None,
                        'hp_max': None,
                        'speed': None
                    }
                    
                    # Look for AC (number)
                    k = j
                    while k < min(j + 10, len(extra_lines)):
                        if extra_lines[k].isdigit() and len(extra_lines[k]) <= 2:
                            if companion['ac'] is None:
                                companion['ac'] = int(extra_lines[k])
                            elif companion['hp_current'] is None:
                                companion['hp_current'] = int(extra_lines[k])
                            elif companion['hp_max'] is None and k > 0 and extra_lines[k - 1] == '/':
                                companion['hp_max'] = int(extra_lines[k])
                        
                        # Speed (e.g., "30")
                        if extra_lines[k].isdigit() and k + 1 < len(extra_lines) and extra_lines[k + 1] == 'ft.':
                            companion['speed'] = int(extra_lines[k])
                        
                        k += 1
                    
                    character['extras']['companions'].append(companion)
    
    return character

def format_as_markdown(character: Dict[str, Any]) -> str:
    """Format character data as clean markdown."""
    output = []
    
    # Header
    output.append(f"# {character['name']}")
    output.append("")
    
    # Basic Info
    if character['basic_info']:
        info = character['basic_info']
        output.append(f"**{info.get('gender', '')}** | **{info.get('race', '')}** | **{info.get('class', '')}**")
        output.append("")
    
    # Combat Stats
    if character['combat_stats']:
        output.append("## Combat Stats")
        stats = character['combat_stats']
        if 'hit_points' in stats:
            hp = stats['hit_points']
            output.append(f"- **HP:** {hp.get('current', '?')}/{hp.get('max', '?')}")
        if 'armor_class' in stats:
            output.append(f"- **AC:** {stats['armor_class']}")
        if 'speed' in stats:
            output.append(f"- **Speed:** {stats['speed']} ft.")
        if 'proficiency_bonus' in stats:
            output.append(f"- **Proficiency Bonus:** +{stats['proficiency_bonus']}")
        output.append("")
    
    # Ability Scores
    if character['ability_scores']:
        output.append("## Ability Scores")
        output.append("")
        for ability, data in character['ability_scores'].items():
            output.append(f"**{ability}:** {data['score']} ({data['modifier']})")
        output.append("")

    # Skills
    if character['skills']:
        output.append("## Skills")
        output.append("")
        for skill in sorted(character['skills'], key=lambda x: x['name']):
            output.append(f"**{skill['name']}:** {skill['ability']} (+{skill['bonus']})")
        output.append("")
    
    
    # Saving Throws
    if character['saving_throws']:
        output.append("## Saving Throws")
        output.append("")
        for save, bonus in character['saving_throws'].items():
            output.append(f"- **{save}:** {bonus}")
        output.append("")
    
    # Senses
    if character['senses']:
        output.append("## Senses")
        output.append("")
        for sense, value in character['senses'].items():
            output.append(f"- **{sense.replace('_', ' ').title()}:** {value}")
        output.append("")
    
    # Proficiencies
    if character['proficiencies']:
        prof = character['proficiencies']
        if any([prof.get('armor'), prof.get('weapons'), prof.get('tools'), prof.get('languages')]):
            output.append("## Proficiencies")
            output.append("")
            if prof.get('armor'):
                output.append(f"**Armor:** {', '.join(prof['armor'])}")
            if prof.get('weapons'):
                output.append(f"**Weapons:** {', '.join(prof['weapons'])}")
            if prof.get('tools'):
                output.append(f"**Tools:** {', '.join(prof['tools'])}")
            if prof.get('languages'):
                output.append(f"**Languages:** {', '.join(prof['languages'])}")
            output.append("")
    
    # Actions
    if character['actions'] and character['actions'].get('attacks'):        
        if character['actions']['attacks']:
            output.append("## Attacks")
            output.append("")
            output.append("| Name | Type | Range | To Hit | Damage |")
            output.append("|------|------|-------|--------|--------|")
            for attack in character['actions']['attacks']:
                name = attack.get('name', '')
                attack_type = attack.get('type', '')
                range_val = attack.get('range', '')
                to_hit = attack.get('to_hit', '')
                damage = attack.get('damage', '')
                output.append(f"| {name} | {attack_type} | {range_val} | {to_hit} | {damage} |")
            output.append("")
    

    # Spells
    if character['spells']:
        spells = character['spells']
        has_spells = any([
            spells.get('cantrips'),
            spells.get('level_1'),
            spells.get('level_2'),
            spells.get('level_3'),
            spells.get('level_4'),
            spells.get('level_5'),
            spells.get('level_6'),
            spells.get('level_7'),
            spells.get('level_8'),
            spells.get('level_9')
        ])
        
        if has_spells or spells.get('spell_attack_bonus') or spells.get('spell_save_dc'):
            output.append("## Spells")
            output.append("")
            
            if spells.get('spell_attack_bonus'):
                output.append(f"**Spell Attack Bonus:** +{spells['spell_attack_bonus']}")
            if spells.get('spell_save_dc'):
                output.append(f"**Spell Save DC:** {spells['spell_save_dc']}")
            if spells.get('spell_attack_bonus') or spells.get('spell_save_dc'):
                output.append("")
            
            if spells.get('cantrips'):
                output.append(f"**Cantrips:** {', '.join(spells['cantrips'])}")
            if spells.get('level_1'):
                output.append(f"**1st Level:** {', '.join(spells['level_1'])}")
            if spells.get('level_2'):
                output.append(f"**2nd Level:** {', '.join(spells['level_2'])}")
            if spells.get('level_3'):
                output.append(f"**3rd Level:** {', '.join(spells['level_3'])}")
            if spells.get('level_4'):
                output.append(f"**4th Level:** {', '.join(spells['level_4'])}")
            if spells.get('level_5'):
                output.append(f"**5th Level:** {', '.join(spells['level_5'])}")
            if spells.get('level_6'):
                output.append(f"**6th Level:** {', '.join(spells['level_6'])}")
            if spells.get('level_7'):
                output.append(f"**7th Level:** {', '.join(spells['level_7'])}")
            if spells.get('level_8'):
                output.append(f"**8th Level:** {', '.join(spells['level_8'])}")
            if spells.get('level_9'):
                output.append(f"**9th Level:** {', '.join(spells['level_9'])}")
            output.append("")
    

    # Features & Traits
    if character['features_and_traits']:
        feat_data = character['features_and_traits']
        has_features = any([
            feat_data.get('class_features'),
            feat_data.get('species_traits'),
            feat_data.get('feats')
        ])
        
        if has_features:
            output.append("## Features & Traits")
            output.append("")
            
            if feat_data.get('class_features'):
                output.append(f"**Class Features:** {', '.join(feat_data['class_features'])}")
            if feat_data.get('species_traits'):
                output.append("**Species Traits:**")
                for trait in feat_data['species_traits']:
                    output.append(f"- {trait}")
            if feat_data.get('feats'):
                output.append(f"**Feats:** {', '.join(feat_data['feats'])}")
            output.append("")
    

    # Equipment
    if character['equipment'] and character['equipment'].get('items'):
        output.append("## Equipment")
        output.append("")
        
        # Group items by type
        items_by_type = {}
        for item in character['equipment']['items']:
            item_type = item.get('type', '')
            item_name = item.get('name', 'Unknown')
            
            # If item name equals type or contains type, change type to "Weapon"
            if item_name == item_type or (item_type and item_type in item_name):
                item_type = 'Weapon'
            
            if item_type == "*":
                item_type = 'Custom'

            if item_type not in items_by_type:
                items_by_type[item_type] = []
            items_by_type[item_type].append(item_name)
        
        # Sort items within each type
        for item_type in items_by_type:
            items_by_type[item_type].sort()
        
        # Custom sort for types: Other types alphabetically, then Gear, then Legacy, then Custom
        def type_sort_key(item_type):
            if item_type == 'Custom':
                return (3, item_type)  # Last
            elif item_type == 'Legacy':
                return (2, item_type)  # Second to last
            elif item_type == 'Gear':
                return (1, item_type)  # Third to last
            else:
                return (0, item_type)  # All others alphabetically
        
        sorted_types = sorted(items_by_type.keys(), key=type_sort_key)
        
        # Output comma-separated lists by type
        for item_type in sorted_types:
            items = items_by_type[item_type]
            items_str = ', '.join(items)
            output.append(f"**{item_type}:** {items_str}")
        
        output.append("")
    

    # Extras (Companions)
    if character['extras'] and character['extras'].get('companions'):
        output.append("## Companions")
        output.append("")
        
        for companion in character['extras']['companions']:
            output.append(f"### {companion.get('name', 'Unknown')}")
            output.append("")
            output.append(f"- **Type:** {companion.get('type', '')}")
            if companion.get('ac'):
                output.append(f"- **AC:** {companion['ac']}")
            if companion.get('hp_current') and companion.get('hp_max'):
                output.append(f"- **HP:** {companion['hp_current']}/{companion['hp_max']}")
            if companion.get('speed'):
                output.append(f"- **Speed:** {companion['speed']} ft.")
            output.append("")
    
    return "\n".join(output)


















def process_character(url: str) -> None:
    """Download and process a single character sheet."""
    # Initialize page_content and character_name
    page_content = None
    character_name = None

    if USE_LOCAL_FILE:
        # Parse from local HTML file
        print(f"Using local file: {USE_LOCAL_FILE}")
        try:
            with open(USE_LOCAL_FILE, "r", encoding='utf-8') as file:
                page_content = file.read()

            # Get the name of the character from the local filename
            character_name = re.sub(r'[<>:"/\\|?*]', '', USE_LOCAL_FILE.rsplit('-', 1)[0]).strip()
            
            print(f"✓ Loaded HTML from {USE_LOCAL_FILE}")
        except FileNotFoundError:
            print(f"✗ Error: File '{USE_LOCAL_FILE}' not found")
        except Exception as e:
            print(f"✗ Error reading file: {e}")
    else:
        print("Starting browser...")
        # Download from web
        with sync_playwright() as p:
            # Launch browser in headless mode
            browser = p.chromium.launch(headless=True)
            context = browser.new_context()
            
            # Add the authentication cookie
            context.add_cookies([{
                'name': 'CobaltSession',
                'value': COBALT_SESSION,
                'domain': '.dndbeyond.com',
                'path': '/'
            }])
            
            page = context.new_page()
            
            print(f"Navigating to {url}...")
            page.goto(url)
            
            print("Waiting 5 seconds for character sheet to load...")
            # Wait for the character sheet element to appear
            try:
                page.wait_for_selector('.ct-character-sheet-desktop', timeout=20000)
                # Give extra time for dynamic content to fully load
                time.sleep(5)
                print("..........5 seconds passed..........")
                
                # Dismiss cookie consent banner if present
                try:
                    # Look for common cookie consent buttons
                    cookie_buttons = [
                        'button:has-text("Accept")',
                        'button:has-text("Accept All")',
                        'button:has-text("I Agree")',
                        'button:has-text("Got it")',
                        '[data-ketch-close]',
                        '.ketch-close-banner'
                    ]
                    for selector in cookie_buttons:
                        try:
                            cookie_btn = page.locator(selector).first
                            if cookie_btn.is_visible(timeout=2000):
                                cookie_btn.click()
                                print("✓ Dismissed cookie consent banner")
                                time.sleep(1)
                                break
                        except:
                            continue
                except Exception as e:
                    print(f"  Note: No cookie banner to dismiss or error: {e}")
                
                # Click through each tab to load dynamic content and save each section
                tabs = [
                    #b('ACTIONS', 'Actions', '.ct-primary-box__tab--actions'),
                    ('SPELLS', 'Spells', '.ct-primary-box__tab--spells'),
                    ('EQUIPMENT', 'Equipment', '.ct-primary-box__tab--equipment'),
                    ('FEATURES_TRAITS', 'Features', '.ct-primary-box__tab--features'),
                    ('EXTRAS', 'Extras', '.ct-primary-box__tab--extras')
                ]
                
                
                print("Saving the initial page...")
                # Get the full page content
                page_content = page.content()
                
                # Extract character name early for file naming
                try:
                    temp_soup = BeautifulSoup(page_content, "html.parser")
                    name_element = temp_soup.find(class_=lambda x: x and x.startswith('styles_characterName'))
                    if name_element:
                        character_name = name_element.get_text().strip()
                        # Sanitize filename - remove invalid characters
                        character_name = re.sub(r'[<>:"/\\|?*]', '', character_name).strip()
                        print(f"✓ Detected character: {character_name}")
                except Exception as e:
                    print(f"  ⚠ Could not extract character name early: {e}")
                
                # Fallback if name not found
                if not character_name:
                    character_name = "Character-" + url.split('/')[-1]
                    print(f"  Using fallback name: {character_name}")
                
                print("Clicking through tabs to load and save dynamic content...")
                for data_testid, tab_name, tab_class in tabs:
                    try:
                        # Find and click the tab button using data-testid attribute
                        # Use force=True to bypass any overlays
                        tab_button = page.locator(f'button.styles_tabButton__wvSLf[data-testid="{data_testid}"]')
                        if tab_button:
                            tab_button.click(force=True, timeout=10000)
                            print(f"  ✓ Clicked {tab_name} tab")
                            # Wait for content to load
                            time.sleep(1)
                            # Wait for the specific tab content to be visible
                            page.wait_for_selector(tab_class, state='visible', timeout=5000)
                            
                            # Extract and save this tab's content
                            tab_element = page.locator(tab_class).first
                            if tab_element:
                                tab_html = tab_element.inner_html()
                                soup = BeautifulSoup(tab_html, "html.parser")
                                # Let's clearly indicate that this is the tab content
                                page_content += "\n\n<div class='tab-content'>" + soup.prettify() + "</div>"
                                print(f"    ✓ Saved {tab_name} content to page content")
                    except Exception as e:
                        print(f"  ⚠ Could not process {tab_name} tab: {e}")
                                    
                # Get the name of the character for logging
                try:
                    soup = BeautifulSoup(page_content, "html.parser")
                    # Find element with class starting with 'styles_characterName'
                    name_element = soup.find(class_=lambda x: x and x.startswith('styles_characterName'))
                    # If unknown, grab the numeric suffix off the URL
                    if not name_element:
                        character_name = "Unknown-" + url.split('/')[-1]
                    else:
                        # Make name url safe and without any spaces
                        character_name = re.sub(r'[<>:"/\\|?*]', '', name_element.get_text().strip()).replace(" ", "")
                    print(f"✓ Loaded character: {character_name}")
                except Exception as e:
                    print(f"  ⚠ Could not get character name: {e}")
                    character_name = "Unknown-" + url.split('/')[-1]

                # Save raw HTML to file
                raw_html_path = os.path.join(OUTPUT_DIR, f"{character_name}-raw.html")
                with open(raw_html_path, "w", encoding='utf-8') as file:
                    file.write(page_content)
                print(f"✓ Raw HTML (with JavaScript rendered) saved to {raw_html_path}")
                    
            except Exception as e:
                print(f"Error: {e}")
                print("The cookie might be expired or invalid.")
                print("Saving whatever content was loaded...")
                # Save whatever we got
                if not character_name:
                    character_name = "Character-" + url.split('/')[-1]
                raw_html_path = os.path.join(OUTPUT_DIR, f"{character_name}-raw.html")
                with open(raw_html_path, "w", encoding='utf-8') as file:
                    file.write(page.content())
                
            finally:
                browser.close()
                print("\nBrowser closed.")

    # Common parsing block - runs if page_content was successfully loaded
    if page_content:
        # Parse the HTML
        soup = BeautifulSoup(page_content, "html.parser")

        # Format the HTML
        formatted_soup = BeautifulSoup(soup.prettify(), "html.parser")  

        # Extract only the ct-character-sheet-desktop section
        character_sheet = formatted_soup.find(class_="ct-character-sheet-desktop")

        # Now append the tab contents if they exist
        for tab_class in [
                      "ct-spells",
                      "ct-equipment",
                      "ct-features",
                      "ct-extras"]:
            tab_section = formatted_soup.find(class_=tab_class)
            if tab_section:
                character_sheet.append(tab_section)
        
        if character_sheet:
            
            character_sheet_annotate = str(character_sheet).replace('ddbc-combat-attack__label">', 'ddbc-combat-attack__label">***ATTACK***')        
            character_sheet_annotate = character_sheet_annotate.replace('ct-inventory-item__heading">', 'ct-inventory-item__heading">***INV***')
            character_sheet_annotate = character_sheet_annotate.replace('ct-feature-snippet--class">', 'ct-feature-snippet--class">***FEATURE***')
            character_sheet_annotate = character_sheet_annotate.replace('ct-feature-snippet--racial-trait">', 'ct-feature-snippet--racial-trait">***RACIAL***')
            character_sheet_annotate = character_sheet_annotate.replace('\u2019', "'")
            
            # Save the full character sheet HTML
            sheet_html_path = os.path.join(OUTPUT_DIR, f"{character_name}-sheet.html")
            with open(sheet_html_path, "w", encoding='utf-8') as file:
                file.write(str(character_sheet_annotate))

            # Get text from the filtered HTML
            character_sheet = BeautifulSoup(character_sheet_annotate, "html.parser")
            sheet_text = character_sheet.get_text()
                    
            # Trim each line and remove empty lines
            lines = sheet_text.splitlines()
            cleaned_lines = [line.strip() for line in lines if line.strip()]
            
            stripped_txt_path = os.path.join(OUTPUT_DIR, f"{character_name}-stripped.txt")
            with open(stripped_txt_path, "w", encoding='utf-8') as file:
                file.write("\n".join(cleaned_lines))
            
            print("✓ Character sheet data successfully processed!")
            print(f"✓ Found {len(cleaned_lines)} lines of character data")
            
            # Parse and format the character data
            raw_text = "\n".join(cleaned_lines)
            character_data = parse_character_data(raw_text)
            
            # Save as Markdown
            markdown_output = format_as_markdown(character_data)
            markdown_path = os.path.join(OUTPUT_DIR, f"{character_name}.md")
            with open(markdown_path, "w", encoding='utf-8') as f:
                f.write(markdown_output)
            print(f"✓ Saved markdown format to {markdown_path}")
            
            # Clean up intermediate files if we downloaded from web
            if DEBUG_IND == "N":
                files_to_delete = [
                    os.path.join(OUTPUT_DIR, f"{character_name}-raw.html"),
                    os.path.join(OUTPUT_DIR, f"{character_name}-sheet.html"),
                    os.path.join(OUTPUT_DIR, f"{character_name}-stripped.txt")
                ]
                for file_path in files_to_delete:
                    try:
                        if os.path.exists(file_path):
                            os.remove(file_path)
                            print(f"✓ Deleted {file_path}")
                    except Exception as e:
                        print(f"⚠ Could not delete {file_path}: {e}")
        else:
            print("✗ Could not find ct-character-sheet-desktop class in the HTML")
            print("Check the HTML file to see what was actually loaded")


#########################
## --- Main Script --- ##
#########################

if __name__ == "__main__":
    
    print("=" * 60)
    
    # Check if local file mode is enabled
    if USE_LOCAL_FILE:
        print("Running in LOCAL FILE mode.\n")  

        try:
            process_character("LOCAL")
            print(f"\n✓ Character completed successfully!")
        except Exception as e:
            print(f"\n✗ Error processing character: {e}")
            import traceback
            traceback.print_exc()      
    else:    
        print(f"Processing {len(urls)} character(s)...\n")
    
        for i, url in enumerate(urls, 1):
            print(f"\n{'=' * 60}")
            print(f"CHARACTER {i}/{len(urls)}")
            print(f"URL: {url}")
            print(f"{'=' * 60}\n")
            
            try:
                process_character(url)
                print(f"\n✓ Character {i} completed successfully!")
            except Exception as e:
                print(f"\n✗ Error processing character {i}: {e}")
                import traceback
                traceback.print_exc()
            
            # Add a small delay between characters to be respectful to the server
            if i < len(urls):
                print(f"\nWaiting 2 seconds before processing next character...")
                time.sleep(2)
    
    print(f"\n{'=' * 60}")
    print(f"COMPLETED: Processed {len(urls)} character(s)")
    print(f"{'=' * 60}\n")    