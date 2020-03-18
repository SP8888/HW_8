DESC profiles;
DESC media ;
DESC users;

--  Проверьте что все значения столбца внешнего ключа входят в 
-- диапазон значений первичного ключа.

SELECT user_id , photo_id FROM profiles ORDER BY user_id ;
SELECT id FROM users u2 ORDER BY id ;
SELECT id FROM media m2 ORDER BY id;
 
ALTER TABLE users DROP COLUMN id;
ALTER TABLE users ADD COLUMN id INT(10) UNSIGNED AUTO_INCREMENT PRIMARY KEY FIRST;

ALTER TABLE profiles DROP COLUMN user_id;
ALTER TABLE profiles ADD COLUMN user_id INT(10) UNSIGNED AUTO_INCREMENT PRIMARY KEY FIRST;


-- Добавляем внешние ключи

ALTER TABLE profiles
  ADD CONSTRAINT profiles_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT profiles_photo_id_fk
    FOREIGN KEY (photo_id) REFERENCES media(id)
      ON DELETE SET NULL;


-- Для таблицы сообщений

ALTER TABLE messages DROP FOREIGN KEY messages_to_user_id_fk;

-- Смотрим структурв таблицы
DESC messages;

-- Добавляем внешние ключи
ALTER TABLE messages
  ADD CONSTRAINT messages_from_user_id_fk 
    FOREIGN KEY (from_user_id) REFERENCES users(id)
    ON DELETE CASCADE,
  ADD CONSTRAINT messages_to_user_id_fk 
    FOREIGN KEY (to_user_id) REFERENCES users(id)
   ON DELETE CASCADE;

SHOW TABLES;

DESC communities_users ;

ALTER TABLE communities_users DROP FOREIGN KEY communities_users_community_id_fk ;
ALTER TABLE communities_users DROP FOREIGN KEY  communities_users_user_id_fk ;

ALTER TABLE communities_users
  ADD CONSTRAINT communities_users_community_id_fk 
    FOREIGN KEY (community_id) REFERENCES communities(id)
    ON DELETE CASCADE,
 ADD CONSTRAINT communities_users_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id)
   ON DELETE CASCADE;
    
DESC family_statuses ;

ALTER TABLE family_statuses DROP FOREIGN KEY family_statuses_id_fk  ;

 ALTER TABLE family_statuses
  ADD CONSTRAINT family_statuses_id_fk 
    FOREIGN KEY (id) REFERENCES users(id)
   ON DELETE CASCADE;
    
DESC friendship;

ALTER TABLE friendship DROP FOREIGN KEY  friendship_user_id_fk ;
ALTER TABLE friendship DROP FOREIGN KEY  friendship_friend_id_fk  ;
ALTER TABLE friendship DROP FOREIGN KEY   friendship_status_id_fk ;

ALTER TABLE friendship 
  ADD CONSTRAINT friendship_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE,
  ADD CONSTRAINT friendship_friend_id_fk 
    FOREIGN KEY (friend_id) REFERENCES users(id)
    ON DELETE CASCADE,
  ADD CONSTRAINT friendship_status_id_fk 
    FOREIGN KEY (status_id) REFERENCES friendship_statuses(id)
   ON DELETE CASCADE;
    
DESC likes ;
DESC target_types;
ALTER TABLE likes DROP FOREIGN KEY  likes_user_id_fk ;
ALTER TABLE likes DROP FOREIGN KEY  likes_target_id_fk ;
ALTER TABLE likes DROP FOREIGN KEY  likes_target_type_id_fk;

ALTER TABLE likes 
  ADD CONSTRAINT likes_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE,
  ADD CONSTRAINT likes_target_id_fk 
    FOREIGN KEY (target_id) REFERENCES users(id)
    ON DELETE CASCADE,
  ADD CONSTRAINT likes_target_type_id_fk 
    FOREIGN KEY (target_type_id) REFERENCES target_types(id)
   ON DELETE CASCADE;
    
DESC media;
DESC media_types ;

ALTER TABLE media DROP FOREIGN KEY media_user_id_fk;
ALTER TABLE media DROP FOREIGN KEY media_type_id_fk ;

ALTER TABLE media 
  ADD CONSTRAINT media_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE,
   ADD CONSTRAINT media_type_id_fk 
    FOREIGN KEY (media_type_id) REFERENCES media_types(id)
   ON DELETE CASCADE;
    
DESC posts ;
DESC communities ;
ALTER TABLE posts DROP FOREIGN KEY posts_user_id_fk;
ALTER TABLE posts DROP FOREIGN KEY posts_community_id_fk ;
ALTER TABLE posts DROP FOREIGN KEY posts_media_id_fk;

ALTER TABLE posts 
  ADD CONSTRAINT posts_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE,
  ADD CONSTRAINT posts_community_id_fk 
    FOREIGN KEY (community_id) REFERENCES communities(id)
    ON DELETE CASCADE,
  ADD CONSTRAINT posts_media_id_fk 
    FOREIGN KEY (media_id) REFERENCES media(id)
   ON DELETE CASCADE;
   

    



-- Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей.

-- первое решение оставил для наглядности, второе уже считает сумму

SELECT 
profiles.user_id AS profil_user,
likes.user_id AS like_user,
profiles.birthdate,
COUNT(likes.user_id) AS total_likes
FROM 
profiles 
LEFT JOIN 
likes 
ON likes.user_id = profiles.user_id
GROUP BY profiles.user_id
ORDER BY profiles.birthdate DESC LIMIT 10;


SELECT SUM(sum_likes) as total_sum FROM (
SELECT 
COUNT(likes.user_id) AS sum_likes
FROM 
profiles 
LEFT JOIN 
likes 
ON likes.user_id = profiles.user_id
GROUP BY profiles.user_id
ORDER BY profiles.birthdate DESC LIMIT 10) as counted_likes;

-- Определить кто больше поставил лайков (всего) - мужчины или женщины?


SELECT 
CASE(gender)
	WHEN 'm' THEN 'MAN'
	WHEN 'f' THEN 'WOMAN'
	END  as chose_sex,
COUNT(*) as count_likes
FROM 
profiles p
JOIN
likes 
ON p.user_id = likes.target_id 
GROUP BY chose_sex 
ORDER by count_likes DESC;


-- Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети.

SELECT * FROM users u ;
SELECT * FROM likes l ;
SELECT * FROM messages m;
SELECT * FROM posts p ;

SELECT 
first_name , last_name,
COUNT(target_id) as likes , 
COUNT(from_user_id) as messages ,
COUNT(p.user_id) as posts 
FROM 
users u
LEFT JOIN
likes l
ON u.id = l.target_id 
left JOIN 
messages m
ON u.id = m.from_user_id
left JOIN 
posts p
ON u.id = p.user_id 
GROUP BY u.id 
ORDER BY target_id, from_user_id, p.user_id LIMIT 10;