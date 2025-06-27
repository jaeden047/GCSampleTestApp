-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.Answers (
  answer_id smallint GENERATED ALWAYS AS IDENTITY NOT NULL,
  question_id integer NOT NULL,
  answer_text text NOT NULL,
  is_correct boolean NOT NULL DEFAULT false,
  CONSTRAINT Answers_pkey PRIMARY KEY (answer_id),
  CONSTRAINT answers_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.Questions(question_id)
);
CREATE TABLE public.Questions (
  question_id smallint GENERATED ALWAYS AS IDENTITY NOT NULL,
  topic_id smallint NOT NULL DEFAULT '1'::smallint,
  question_text text,
  CONSTRAINT Questions_pkey PRIMARY KEY (question_id),
  CONSTRAINT Questions_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES public.Topics(topc_id)
);
CREATE TABLE public.TestAttempts (
  attempt_id integer NOT NULL DEFAULT nextval('testattempts_attempt_id_seq'::regclass),
  user_id uuid NOT NULL,
  test_datetime timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  question_list ARRAY,-- list of 10 questions that was randomly selected
  answer_order ARRAY, -- list of multiple choice answers in its displayed order e.q. "[[21,19,23,20],[24,25,26,27],..." 
  selected_answers ARRAY, -- the 10 answers that was selected by the user
  score numeric,
  CONSTRAINT TestAttempts_pkey PRIMARY KEY (attempt_id),
  CONSTRAINT testattempts_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
-- each topic has a book of questions where we randomly select 10 for the quiz
CREATE TABLE public.Topics (
  topc_id smallint GENERATED ALWAYS AS IDENTITY NOT NULL,
  topic_name text NOT NULL, -- e.q. grade 7, grade 8 or environmental topics
  CONSTRAINT Topics_pkey PRIMARY KEY (topc_id)
);