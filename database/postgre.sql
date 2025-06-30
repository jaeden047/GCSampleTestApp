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
  topic_name text NOT NULL,
  CONSTRAINT topics_pkey PRIMARY KEY (topic_id)
);
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
  question_list ARRAY,
  answer_order ARRAY,
  selected_answers ARRAY,
  score numeric,
  CONSTRAINT test_attempts_pkey PRIMARY KEY (attempt_id),
  CONSTRAINT testattempts_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);