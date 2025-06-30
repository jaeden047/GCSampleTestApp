-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.profiles (
  id uuid NOT NULL,
  name text,
  email text,
  phone_number text,
  created_at timestamp without time zone DEFAULT now(),
  school text,
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.topics (
  topic_id smallint GENERATED ALWAYS AS IDENTITY NOT NULL,
  topic_name text NOT NULL,-- e.q. grade 7, grade 8 or environmental topics
  CONSTRAINT topics_pkey PRIMARY KEY (topic_id)
);-- each topic has a book of questions where we randomly select 10 for the quiz
CREATE TABLE public.questions (
  question_id smallint GENERATED ALWAYS AS IDENTITY NOT NULL,
  topic_id smallint NOT NULL DEFAULT '1'::smallint,
  question_text text,
  CONSTRAINT questions_pkey PRIMARY KEY (question_id),
  CONSTRAINT Questions_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES public.topics(topic_id)
);
CREATE TABLE public.answers (
  answer_id smallint GENERATED ALWAYS AS IDENTITY NOT NULL,
  question_id integer NOT NULL,
  answer_text text NOT NULL,
  is_correct boolean NOT NULL DEFAULT false,
  CONSTRAINT answers_pkey PRIMARY KEY (answer_id),
  CONSTRAINT answers_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions(question_id)
);
CREATE TABLE public.test_attempts (
  attempt_id integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  user_id uuid NOT NULL,
  test_datetime timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  question_list ARRAY, -- list of 10 questions that was randomly selected
  answer_order ARRAY, -- list of multiple choice answers in its displayed order e.q. "[[21,19,23,20],[24,25,26,27],..." 
  selected_answers ARRAY, -- the 10 answers that was selected by the user
  score numeric,
  CONSTRAINT test_attempts_pkey PRIMARY KEY (attempt_id),
  CONSTRAINT testattempts_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);