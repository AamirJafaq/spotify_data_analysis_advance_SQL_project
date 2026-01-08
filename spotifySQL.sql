DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
artist VARCHAR(255),
track VARCHAR(255),
album VARCHAR(255),
album_type VARCHAR(50),
danceability FLOAT,
energy FLOAT,
loadness FLOAT,
speechiness FLOAT,
acousticness FLOAT,
instrumentalness FLOAT,
liveness FLOAT,
valence FLOAT,
tempo FLOAT,
duration_min FLOAT,
title VARCHAR(255),
channel VARCHAR(255),
views FLOAT, 
likes BIGINT,
comments BIGINT,
licencsed BOOLEAN,
official_video BOOLEAN,
stream BIGINT,
energy_liveness FLOAT, 
most_played_on VARCHAR(50)
);

-- Exploratory Data Analysis
SELECT count(*) FROM spotify;
-- There are 20594 obervations

SELECT count(DISTINCT album) FROM spotify;
-- There are 11854 different albums.

SELECT count(DISTINCT artist) FROM spotify;
-- There are 2074 different artists.

SELECT max(duration_min) AS max_durationm, min(duration_min) AS min_duration FROM spotify;
/* The max duration is 77.9. However, min duration is 0 which is impractical. It means the has inconsistencies.
Therefore, search for those records and delet them.  */

SELECT * FROM spotify 
WHERE duration_min=0;

DELETE FROM spotify
WHERE duration_min=0;
-- The records with zero duration_min are removed.

------------------------------------------------------------------------
-- Data Analysis
-- Q.1 Retrieve the name of all tracks that have more than 1 billions streams.
SELECT * FROM spotify
WHERE stream > 1000000000; -- There are 385 tracks with more than 1 billion streams.


-- Q.2 List all albums along with their respective artists.
SELECT DISTINCT album, artist 
FROM spotify
ORDER BY album;


-- Q.3 Get the total number of comments for tracks where licensed=True.
SELECT sum(comments) AS total_comments
FROM spotify
WHERE licencsed=TRUE;

-- Q.4 Find the tracks that belong to the album type single.
SELECT track
FROM spotify
WHERE album_type='single'; -- There are 4973 tracks.


-- Q.5 Count the total number of tracks by each artist.
SELECT artist, count(track) AS total_tracks
FROM spotify
GROUP BY artist
ORDER BY 2 DESC;

-- Q.6 Calculate the average danceability of tracks in each album.
SELECT album, avg(danceability) AS avg_danceability
FROM spotify
GROUP BY album
ORDER BY 2 DESC;


-- Q.7 Find the top 5 tracks with the highest energy values.
SELECT track, max(energy)
FROM spotify
GROUP BY track
ORDER BY avg(energy) DESC
LIMIT 5;


-- Q.8 List all tracks along with their views and likes where official_video=True.
SELECT track, sum(views) AS total_views, sum(likes) AS total_likes
FROM spotify
WHERE official_video=TRUE
GROUP BY track
ORDER BY total_views DESC;


-- Q.9 For each album, calculate the total views of all associated tracks.
SELECT album, track AS total_tracks, sum(views) AS total_views
FROM spotify
GROUP BY album, track
ORDER BY total_views DESC;


-- Q.10 Retrieve the track names that have been streamed on spotify more than YouTube.
WITH yt_sp AS (SELECT track, SUM(CASE WHEN most_played_on='Spotify' THEN stream ELSE 0 END) AS total_spotify_played,
	SUM(CASE WHEN most_played_on='Youtube' THEN stream ELSE 0 END) AS total_youtube_played
FROM spotify
GROUP BY track)
SELECT track, total_spotify_played, total_youtube_played
FROM yt_sp
WHERE total_spotify_played > total_youtube_played AND total_youtube_played <> 0
ORDER BY total_spotify_played DESC;
--or
SELECT * 
FROM (SELECT track, SUM(CASE WHEN most_played_on='Spotify' THEN stream ELSE 0 END) AS total_spotify_played,
	SUM(CASE WHEN most_played_on='Youtube' THEN stream ELSE 0 END) AS total_youtube_played
FROM spotify
GROUP BY track)
WHERE total_spotify_played > total_youtube_played  AND total_youtube_played <> 0
ORDER BY total_spotify_played DESC;


--  Q.11 Find the top 3 most-viewed tracks for each artist using window functions.
SELECT * 
FROM (SELECT artist, track, sum(views) AS total_views, DENSE_RANK() OVER (PARTITION BY artist ORDER BY sum(views) DESC) AS ranking
FROM spotify
GROUP BY artist, track)
WHERE ranking IN (1, 2, 3);
--or
WITH tracks_ranking AS (
SELECT artist, track, sum(views) AS total_views, DENSE_RANK() OVER (PARTITION BY artist ORDER BY sum(views) DESC) AS ranking
FROM spotify
GROUP BY artist, track
)
SELECT * 
FROM tracks_ranking 
WHERE ranking <= 3;


-- Q.12 Write a query to find tracks where the liveness score is above the average.
SELECT track, liveness
FROM spotify
WHERE liveness > (SELECT avg(liveness) FROM spotify);


-- Q.13 Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
WITH energy_levels AS (SELECT album, MAX(energy) AS highest_energy, MIN(energy) AS lowest_energy
FROM spotify
GROUP BY album)
SELECT *, highest_energy-lowest_energy AS energy_difference
FROM energy_levels
ORDER BY energy_difference DESC; 


-- Q.14 Find tracks where the energy-to-liveness ratio is greater than 1.2
SELECT * 
FROM (SELECT track, energy, liveness, energy/liveness AS ratio
FROM spotify
ORDER BY ratio DESC)
WHERE ratio > 1.2;


-- Q.15 Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
SELECT track, likes, views, 
			SUM(likes) OVER (ORDER BY views DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_sum_likes 
FROM spotify;
