
USE ROLE SYSADMIN;
CREATE SCHEMA IF NOT EXISTS WPA.DATA;
USE SCHEMA WPA.DATA;

-- Update Locations

UPDATE STG_MESSAGES SET LOCATION_NAME =
CASE WHEN LOCATION_NAME = 'City of Lights: the-borealis' THEN 'East Island: City of Lights - The Borealis'
    WHEN LOCATION_NAME = 'South Island: mirewatch-outpost' THEN 'South Island: Mirewatch Outpost'
    WHEN LOCATION_NAME = 'West Island: calamari-cove-outpost' THEN 'West Island: Calamari Cove Outpost'
    WHEN LOCATION_NAME = 'West Island: ifol-canyon' THEN 'West Island: Ifol Canyon'
    WHEN LOCATION_NAME = 'West Island: inundated-plains' THEN 'West Island: Inundated Plains'
    WHEN LOCATION_NAME = 'West Island: lake-ifol' THEN 'West Island: Lake Ifol'
    WHEN LOCATION_NAME = 'autumnal-forest: A slow walk to verdant' THEN 'East Island: Autumnal Forest'
    WHEN LOCATION_NAME = 'autumnal-forest: Slow Stroll in the Autumnal Forest' THEN 'East Island: Autumnal Forest'
    WHEN LOCATION_NAME = 'cold-jungle-canopy: Slow stroll in a glacial wasteland' THEN 'East Island: Cold Jungle Canopy'
    WHEN LOCATION_NAME = 'cold-jungle-floor: A slow walk to verdant' THEN 'East Island: Cold Jungle Floor'
    WHEN LOCATION_NAME = 'frozen-river: Slow stroll to the Frozen River' THEN 'East Island: Frozen River'
    WHEN LOCATION_NAME = 'mirewatch-outpost: The Muddy Pitch' THEN 'South Island: Mirewatch Outpost - The Muddy Pitch'
    WHEN LOCATION_NAME = 'snowy-hill: Slow stroll on a Snowy Hill' THEN 'East Island: Snowy Hill'
    WHEN LOCATION_NAME = 'swamp: A slow walk to Mirewatch' THEN 'South Island: Swamp'
    WHEN LOCATION_NAME = 'swamp: The Hunt for Oona' THEN 'South Island: Swamp'
    WHEN LOCATION_NAME = 'temple: Temple Corner' THEN 'East Island: City of Lights - Temple'
    WHEN LOCATION_NAME = 'the-caravansary: A slow stroll out of the City' THEN 'East Island: City of Lights - The Caravansary'
    WHEN LOCATION_NAME = 'verdant-hills: A slow walk to verdant' THEN 'East Island: Verdant Hills'
    WHEN LOCATION_NAME = 'woodlands: A slow walk to Mirewatch' THEN 'East Island: Woodlands'
    ELSE LOCATION_NAME
END;

INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, MSG_TIMESTAMP, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
VALUES (1, 0, 1000005, '2024-11-27 04:57:10'::TIMESTAMP_NTZ, 'East Island: Autumnal Forest', 'Dungeon Master', '>>> *A band of adventurers begins their journey in the Autumnal Forest, a place of vibrant colors and gentle breezes. As they walk along a winding path, the leaves crunch softly underfoot, and the scent of pine and earth fills the air.*') ;

UPDATE STG_MESSAGES SET LOCATION_NAME = LOCATION_NAME || ' (ENCOUNTER)' WHERE MESSAGE = 'Start Init' AND LOCATION_NAME NOT LIKE '%(ENCOUNTER)%';
UPDATE STG_MESSAGES SET LOCATION_NAME = 'East Island: Cold Jungle Floor (ENCOUNTER)' WHERE THREAD_MSG_NUM >= 2000380 AND THREAD_MSG_NUM <= 2000890;
UPDATE STG_MESSAGES SET LOCATION_NAME = 'East Island: Verdant Hills (ENCOUNTER)' WHERE THREAD_MSG_NUM >= 3000200 AND THREAD_MSG_NUM <= 3000640;
UPDATE STG_MESSAGES SET LOCATION_NAME = 'East Island: Woodlands (ENCOUNTER)' WHERE THREAD_MSG_NUM >= 4000360 AND THREAD_MSG_NUM <= 4000840;
UPDATE STG_MESSAGES SET LOCATION_NAME = 'South Island: Swamp (ENCOUNTER)' WHERE THREAD_MSG_NUM >= 5000210 AND THREAD_MSG_NUM <= 5000900;
UPDATE STG_MESSAGES SET LOCATION_NAME = 'South Island: Mirewatch Outpost - The Muddy Pitch (Card Game)' WHERE THREAD_MSG_NUM >= 7000110 AND THREAD_MSG_NUM <= 7000330;
UPDATE STG_MESSAGES SET LOCATION_NAME = 'South Island: Swamp (ENCOUNTER)' WHERE THREAD_MSG_NUM >= 8000610 AND THREAD_MSG_NUM <= 8001910;
UPDATE STG_MESSAGES SET LOCATION_NAME = 'South Island: Swamp (ENCOUNTER)' WHERE THREAD_MSG_NUM >= 8002250 AND THREAD_MSG_NUM <= 8004290;
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, MSG_TIMESTAMP, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
VALUES (8, 0, 8004525, '2024-12-30 17:32:24'::TIMESTAMP_NTZ, 'South Island: Swamp - Feligrinn\'s Home', 'Dungeon Master', 'New Scene');

UPDATE STG_MESSAGES SET LOCATION_NAME = 'South Island: Swamp - Feligrinn\'s Home' WHERE THREAD_MSG_NUM >= 8004530 AND THREAD_MSG_NUM <= 8005070;
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, MSG_TIMESTAMP, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
VALUES (8, 0, 8005075, '2025-01-04 16:49:56'::TIMESTAMP_NTZ, 'South Island: Swamp', 'Dungeon Master', 'New Scene');
UPDATE STG_MESSAGES SET LOCATION_NAME = 'South Island: Swamp (ENCOUNTER)' WHERE THREAD_MSG_NUM >= 8005570 AND THREAD_MSG_NUM <= 8006650;
UPDATE STG_MESSAGES SET CHARACTER_NAME = 'Skye' WHERE CHARACTER_NAME = 'Koala';
UPDATE STG_MESSAGES SET LOCATION_NAME = 'South Island: Swamp - Feligrinn\'s Home' WHERE THREAD_MSG_NUM >= 9000010 AND THREAD_MSG_NUM <= 9001160;
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, MSG_TIMESTAMP, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
VALUES (9, 0, 9001165, '2025-01-22 08:43:03'::TIMESTAMP_NTZ, 'South Island: Swamp', 'Dungeon Master', 'New Scene');
DELETE FROM STG_MESSAGES WHERE MESSAGE ILIKE '%Changed the channel name%';
UPDATE STG_MESSAGES SET LOCATION_NAME = 'South Island: Swamp (ENCOUNTER)' WHERE THREAD_MSG_NUM >= 9001220 AND THREAD_MSG_NUM <= 9001690;
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, MSG_TIMESTAMP, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
VALUES (9, 0, 9001695, '2025-01-24 19:15:02'::TIMESTAMP_NTZ, 'South Island: Swamp', 'Dungeon Master', 'New Scene');
UPDATE STG_MESSAGES SET LOCATION_NAME = 'South Island: Swamp - Oona\'s Hilltop (ENCOUNTER)' WHERE THREAD_MSG_NUM >= 9001800 AND THREAD_MSG_NUM <= 9004610;
UPDATE STG_MESSAGES SET THREAD_MSG_NUM = 9001795 WHERE THREAD_MSG_NUM = 9001820;  -- Push back for open scene for Oona's Hilltop
UPDATE STG_MESSAGES SET LOCATION_NAME = 'South Island: Swamp - Oona\'s Hilltop' WHERE THREAD_MSG_NUM >= 9004620 AND THREAD_MSG_NUM <= 9005930;
UPDATE STG_MESSAGES SET LOCATION_NAME = 'West Island: Inundated Plains (ENCOUNTER)' WHERE THREAD_MSG_NUM >= 10000180 AND THREAD_MSG_NUM <= 10001430;
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, MSG_TIMESTAMP, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
VALUES (13, 0, 13000060, '2025-02-13 14:29:40'::TIMESTAMP_NTZ, 'West Island: Calamari Cove Outpost', 'Dungeon Master', '>>> *After a brief respite in the Outpost, the party decides to teleport back to the City of Lights for a comfortable night\'s rest. The party agrees to meet up back at the Borealis the next morning.  Mina informs the party that she won\'t be joining them, but must be off to take care of some familiy businesss.');
UPDATE STG_MESSAGES SET THREAD_MSG_NUM = 14000015 WHERE THREAD_MSG_NUM = 14000010;  -- Push back for opening scene for the City of Lights thead

INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, MSG_TIMESTAMP, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
VALUES (14, 0, 14000010, '2025-02-23 07:53:12'::TIMESTAMP_NTZ, 'East Island: City of Lights - The Borealis', 'Dungeon Master', '>>> The remaining members of the party (Aillig, Ra, and Quinn) all get a well deserved long rest and slowly begin to make their way into the Borealis.* (The day is yours, what do you do?)');
-- Updates
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, MSG_TIMESTAMP, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
VALUES (17, 0, 17000885, '2025-02-26 21:44:55'::TIMESTAMP_NTZ, 'East Island: Autumnal Forest - Riverside', 'Dungeon Master', 'New Scene');
UPDATE STG_MESSAGES SET LOCATION_NAME = 'East Island: Autumnal Forest - Riverside' WHERE THREAD_MSG_NUM >= 17000885 AND THREAD_MSG_NUM <= 17001330;
UPDATE STG_MESSAGES SET LOCATION_NAME = 'East Island: Autumnal Forest - Riverside (ENCOUNTER)' WHERE THREAD_MSG_NUM >= 17001340 AND THREAD_MSG_NUM <= 17001690;
UPDATE STG_MESSAGES SET THREAD_MSG_NUM = 17001695 WHERE THREAD_MSG_NUM = 17001680;  -- Push back End Init to capture final msg of battle
UPDATE STG_MESSAGES SET LOCATION_NAME = 'East Island: Autumnal Forest - Riverside' WHERE THREAD_MSG_NUM >= 17001700 AND THREAD_MSG_NUM <= 17002070;

INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, MSG_TIMESTAMP, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
VALUES (17, 0, 17002075, '2025-03-02 14:23:17'::TIMESTAMP_NTZ, 'East Island: Autumnal Forest - Crimson Grove', 'Dungeon Master', 'New Scene');

UPDATE STG_MESSAGES SET THREAD_MSG_NUM = 17002536 WHERE THREAD_MSG_NUM = 17002520;  -- Push back New Scene message
UPDATE STG_MESSAGES SET LOCATION_NAME = 'East Island: Autumnal Forest - Crimson Grove' WHERE THREAD_MSG_NUM >= 17002080 AND THREAD_MSG_NUM <= 17002530;
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, MSG_TIMESTAMP, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
VALUES (17, 0, 17002533, '2025-03-03 18:14:07'::TIMESTAMP_NTZ, 'East Island: Autumnal Forest - Edrik\'s Cottage', 'Dungeon Master', 'New Scene');
UPDATE STG_MESSAGES SET LOCATION_NAME = 'East Island: Autumnal Forest - Edrik\'s Cottage' WHERE THREAD_MSG_NUM >= 17002533 AND THREAD_MSG_NUM <= 17003500;
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, MSG_TIMESTAMP, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
VALUES (17, 0, 17003505, '2025-03-09 14:49:54'::TIMESTAMP_NTZ, 'East Island: Autumnal Forest - Westward Path', 'Dungeon Master', 'New Scene');
UPDATE STG_MESSAGES SET LOCATION_NAME = 'East Island: Autumnal Forest - Westward Path' WHERE THREAD_MSG_NUM >= 17003505 AND THREAD_MSG_NUM <= 17003800;
UPDATE STG_MESSAGES SET LOCATION_NAME = 'East Island: Autumnal Forest - Westward Path (ENCOUNTER)' WHERE THREAD_MSG_NUM >= 17003810 AND THREAD_MSG_NUM <= 17006720;
UPDATE STG_MESSAGES SET LOCATION_NAME = 'East Island: Autumnal Forest - Westward Path' WHERE THREAD_MSG_NUM >= 17006730 AND THREAD_MSG_NUM <= 17006880;
DELETE FROM STG_MESSAGES WHERE THREAD_MSG_NUM = 17006890 OR THREAD_MSG_NUM = 17006900;  -- Ignore hp updates
UPDATE STG_MESSAGES SET THREAD_MSG_NUM = 18000019 WHERE THREAD_MSG_NUM = 18000010; 
UPDATE STG_MESSAGES SET THREAD_MSG_NUM = 18000018 WHERE THREAD_MSG_NUM = 17006970; 
UPDATE STG_MESSAGES SET THREAD_MSG_NUM = 18000017 WHERE THREAD_MSG_NUM = 17006960; 
UPDATE STG_MESSAGES SET THREAD_MSG_NUM = 18000016 WHERE THREAD_MSG_NUM = 17006950; 
UPDATE STG_MESSAGES SET THREAD_MSG_NUM = 18000015 WHERE THREAD_MSG_NUM = 17006940; 
UPDATE STG_MESSAGES SET THREAD_MSG_NUM = 18000014 WHERE THREAD_MSG_NUM = 17006930; 
UPDATE STG_MESSAGES SET THREAD_MSG_NUM = 18000013 WHERE THREAD_MSG_NUM = 17006920; 
UPDATE STG_MESSAGES SET THREAD_MSG_NUM = 18000012 WHERE THREAD_MSG_NUM = 17006910; 
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, MSG_TIMESTAMP, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
VALUES (18, 0, 18000010, '2025-03-14 10:52:26'::TIMESTAMP_NTZ, 'East Island: Frozen River', 'Dungeon Master', '>>> *Eventually the trees thin and your boots crunch on a carpet of fallen leaves. A sudden gust whips through the branches, sending a new flurry of leaves swirling to the ground. The air temperature turns brisk and the scent of the forest is replaced by a crisp bite of approaching frost. In the distance, beyond the rolling hills, storm clouds gather on the horizon.  The path ahead winds into the open wilds, where the whispering wind carries with it an eerie howl.*');
UPDATE STG_MESSAGES SET MESSAGE = '>>> *Quinn is leading the way - trusting her instincts and keeping the party safe.  With careful footing and keen eyes, most of the party follows the twisting trail through the forest with ease.  At one point Ra’vek gets tripped up by some hidden roots while talking to Klymok overhead, but he nimbly recovers.*' WHERE THREAD_MSG_NUM = 17006880;
UPDATE STG_MESSAGES SET LOCATION_NAME = 'East Island: Frozen River' WHERE THREAD_MSG_NUM >= 18000010 AND THREAD_MSG_NUM <= 18000018;
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, MSG_TIMESTAMP, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
VALUES (18, 0, 18000316, '2025-03-15 21:00:40'::TIMESTAMP_NTZ, 'East Island: Frozen River (ENCOUNTER)', 'Dungeon Master', 'Start Init');
UPDATE STG_MESSAGES SET LOCATION_NAME = 'East Island: Frozen River (ENCOUNTER)' WHERE THREAD_MSG_NUM >= 18000316 AND THREAD_MSG_NUM <= 18002310;
UPDATE STG_MESSAGES SET LOCATION_NAME = 'East Island: Snowy Hill (ENCOUNTER)' WHERE THREAD_MSG_NUM >= 19000300 AND THREAD_MSG_NUM <= 19002230;
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, MSG_TIMESTAMP, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
VALUES (20, 0, 20000055, '2025-03-25 05:51:24'::TIMESTAMP_NTZ, 'East Island: Cold Jungle Canopy (ENCOUNTER)', 'Dungeon Master', 'New Scene');
UPDATE STG_MESSAGES SET LOCATION_NAME = 'East Island: Cold Jungle Canopy (ENCOUNTER)' WHERE THREAD_MSG_NUM >= 20000055 AND THREAD_MSG_NUM <= 20000210;
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, MSG_TIMESTAMP, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
VALUES (20, 0, 20000705, '2025-03-27 14:28:29'::TIMESTAMP_NTZ, 'East Island: Cold Jungle Canopy (ENCOUNTER)', 'Dungeon Master', 'New Scene');
UPDATE STG_MESSAGES SET LOCATION_NAME = 'East Island: Cold Jungle Canopy (ENCOUNTER)' WHERE THREAD_MSG_NUM >= 20000710 AND THREAD_MSG_NUM <= 20001090;
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, MSG_TIMESTAMP, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
VALUES (20, 0, 20001405, '2025-03-31 19:49:48'::TIMESTAMP_NTZ, 'East Island: Cold Jungle Canopy (ENCOUNTER)', 'Dungeon Master', 'New Scene');
UPDATE STG_MESSAGES SET LOCATION_NAME = 'East Island: Cold Jungle Canopy (ENCOUNTER)' WHERE THREAD_MSG_NUM >= 20001410 AND THREAD_MSG_NUM <= 20001470;
UPDATE STG_MESSAGES SET THREAD_MSG_NUM = 21000005 WHERE THREAD_MSG_NUM = 21000010;  -- Start of WPA!  Alter so it continues prior scene.
UPDATE STG_MESSAGES SET LOCATION_NAME = 'East Island: Cold Jungle Canopy' WHERE THREAD_MSG_NUM >= 21000005 AND THREAD_MSG_NUM <= 21000280;
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, MSG_TIMESTAMP, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
VALUES (21, 0, 21000285, '2025-04-03 16:02:07'::TIMESTAMP_NTZ, 'East Island: Glacial Ridge', 'Dungeon Master', 'New Scene');
UPDATE STG_MESSAGES SET LOCATION_NAME = 'Mountains: Glacial Ridge' WHERE THREAD_MSG_NUM >= 21000285 AND THREAD_MSG_NUM <= 21001560;
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, MSG_TIMESTAMP, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
VALUES (21, 0, 21001565, '2025-04-06 05:53:28'::TIMESTAMP_NTZ, 'Mountains: Isanya\'s Spine', 'Dungeon Master', 'New Scene');
UPDATE STG_MESSAGES SET LOCATION_NAME = 'Mountains: Isanya\'s Spine' WHERE THREAD_MSG_NUM >= 21001565 AND THREAD_MSG_NUM <= 21002870;

INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, MSG_TIMESTAMP, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
VALUES (21, 0, 21002875, '2025-04-08 15:44:44'::TIMESTAMP_NTZ, 'Mountains: Isanya\'s Spine (ENCOUNTER)', 'Dungeon Master', 'New Scene');
UPDATE STG_MESSAGES SET LOCATION_NAME = 'Mountains: Isanya\'s Spine (ENCOUNTER)' WHERE THREAD_MSG_NUM >= 21002875 AND THREAD_MSG_NUM <= 21003030;
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, MSG_TIMESTAMP, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
VALUES (21, 0, 21003035, '2025-04-09 18:01:32'::TIMESTAMP_NTZ, 'Mountains: Isanya\'s Spine', 'Dungeon Master', 'New Scene');
UPDATE STG_MESSAGES SET LOCATION_NAME = 'Mountains: Isanya\'s Spine' WHERE THREAD_MSG_NUM >= 21003035 AND THREAD_MSG_NUM <= 21003860;
UPDATE STG_MESSAGES SET MESSAGE = '> *Ra\'vek and Quinn are quick to move and leap to the side to avoid falling into a deep hole.  Darias and Aillig unfortunately were caught off guard and start slipping.  Aillig\'s quick sigil work prevent any damage and they land  on top of a pile of ice and snow, 20 feet down.*' WHERE THREAD_MSG_NUM = 21003860;
INSERT INTO STG_MESSAGES (THREAD_ID, MSG_ID, THREAD_MSG_NUM, MSG_TIMESTAMP, LOCATION_NAME, CHARACTER_NAME, MESSAGE)
VALUES (21, 0, 21003875, '2025-04-11 11:08:55'::TIMESTAMP_NTZ, 'Mountains: Isanya\'s Spine (ENCOUNTER)', 'Dungeon Master', '> *The noise of the cracking and falling ice, along with the parties yelling floats in the wind... and far above, shapes begin to circle. A screech tears through the cold sky and you see them dive!*
> 
(What do you do?)');

UPDATE STG_MESSAGES SET LOCATION_NAME = 'Mountains: Isanya\'s Spine (ENCOUNTER)' WHERE THREAD_MSG_NUM >= 21003870 AND THREAD_MSG_NUM <= 21006780;

