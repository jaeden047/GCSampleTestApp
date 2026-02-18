-- Bulk insert questions and answers INTO A QUESTION SET (refactor schema)
-- 1. Set topic name, round, and set_number below (e.g. Grade 11 and 12, sample, 1).
-- 2. Add rows in the VALUES list: (question_text, ans1, ans2, ans3, ans4, correct_which).
--


DO $$
DECLARE
 p_topic_name text := 'Grade 11 and 12';   -- CHANGE: topic name (e.g. 'Grade 5 and 6', 'Grade 11 and 12')
 p_round text := 'sample';                  -- CHANGE: 'sample', 'local', or 'final' (use 'main' for Plastic Pollution)
 p_set_number smallint := 1;                -- CHANGE: 1 for sample; 1-4 for local/final
 p_set_id smallint;
 p_topic_id smallint;   -- for INSERT if questions.topic_id still exists
 r RECORD;
 qid smallint;
BEGIN
 -- Resolve (topic_name, round, set_number) -> set_id and topic_id
 SELECT qs.set_id, qs.topic_id INTO p_set_id, p_topic_id
 FROM question_sets qs
 JOIN topics t ON t.topic_id = qs.topic_id
 WHERE t.topic_name = p_topic_name
   AND qs.round = p_round
   AND qs.set_number = p_set_number
 LIMIT 1;


 IF p_set_id IS NULL THEN
   RAISE EXCEPTION 'No question_set found for topic_name=%, round=%, set_number=%. Run Phase 1 migration first.', p_topic_name, p_round, p_set_number;
 END IF;


 FOR r IN
   SELECT * FROM (VALUES
     -- (question_text, ans1, ans2, ans3, ans4, correct_which)  -- correct_which = 1,2,3, or 4
      (
       'A farmer wants to enclose a rectangular field (with one side along the river) with 200 meters of fencing. Which expression below represents the area of the field as a function of the side perpendicular to the river, and what dimensions maximize the area?',
       'Area: A(x)=x(100-x), Maximum when x=50 m, length along river = 100 m',
       'Area: A(x)=x(200-2x); Maximum when x=50 m, length along river = 100 m',
       'Area: A(x)=x(100-x/2);  Maximum when x=50 m, length along river =100 m',
       'Area: A(x)=x(200-2x); Maximum when x=40 m, length along river = 120 m',
       2
      ),(
       'A regular hexagon is inscribed in a circle of radius 6. What is the area of the hexagon?',
       '36sqrt(3)',
       '54sqrt(3)',
       '72sqrt(3)',
       '72sqrt(3)',
       2
      ),(
       'If $z = 1 + i$, what is $z^{10}$ in standard form?',
       '16i',
       '-32i',
       '32i',
       '-32',
       3
      ),(
       'A rectangle has a perimeter of 60 cm. If the length is twice the width, what is the area of the rectangle?',
       '50 cm²',
       '100 cm²',
       '180 cm²',
       '200 cm²',
       4
      ),(
       'A train travels 300 km at a constant speed. If the speed were increased by 10 km/h, the trip would take 1 hour less. What is the original speed of the train?',
       '50 km/h',
       '60 km/h',
       '70 km/h',
       '80 km/h',
       1
      ),(
       'If $f(x)=sin(3x^2)$, what is $f''(x)$?',
       '$3xcos(3x^2)$',
       '$6xcos(3x^2)$',
       '$6xsin(3x^2)$',
       '$3xsin(3x^2)$',
       2
      ),(
       'What is the derivative of $f(x)=x/(x^2+1)$?',
       '$(1+x^2)/(x^2+1)^2$',
       '$(1-2x^2)/(x^2+1)^2$',
       '$(1+2x^2)/(x^2+1)^2$',
       '$(1-x^2)/(x^2+1)^2$',
       4
      ),(
       'The contrapositive of "If a number is even, then it is divisible by 2" is:',
       'If a number is not even, then it is not divisible by 2.',
       'If a number is not divisible by 2, then it is not even.',
       'If a number is divisible by 2, then it is even.',
       'If a number is odd, then it is divisible by 2.',
       2
      ),(
       'The standard deviation of the data set {2, 2, 2, 2, 2} is:',
       '0',
       '1',
       '2',
       'Undefined',
       1
      ),(
       'The data set {4,6,8,10,12} has a mean and a median of 8. If the number 20 is added to the set, what is the difference between the new mean and the new median?',
       '0',
       '1',
       '2',
       '3',
       2
      ),(
       'A square, a circle, and an equilateral triangle have the same perimeter. Which one has the larger area?',
       'Same area',
       'Square',
       'Triangle',
       'Circle',
       4
      ),(
       'A car travels the first half of the distance of a road trip at 40 km/h and the second half at 60 km/h. What is the average speed for the entire journey?',
       '55 km/h',
       '50 km/h',
       '52 km/h',
       '48 km/h',
       4
      ),(
       'Find the smallest positive value of x such that tanx = cotx.',
       '30°',
       '45°',
       '60°',
       '90°',
       2
      ),(
       'Which of the following numbers is prime?',
       '121',
       '133',
       '151',
       '169',
       3
      ),(
       'Find the sum of reciprocals of the roots of the equation: $x^2-5x+6=0$',
       '5/6',
       '1/2',
       '1',
       '3/2',
       1
      ),(
       'Acceleration is the derivative of velocity which is the derivative of position. If the position of a ball is given as $s(t) = t^3 - 6t^2 + 9t - 4$ for time t, determine the signs of velocity and acceleration at t = 3.',
       'Velocity is negative, acceleration is positive',
       'Velocity is zero, acceleration is negative',
       'Velocity is zero, acceleration is positive',
       'Velocity is negative, acceleration is zero',
       3
      ),(
       'The complex number z satisfies |z + 2 - i| = |z - 3 + 2i|. The locus of z in the complex plane is:',
       'A straight line',
       'A straight line parallel to the imaginary axis',
       'A straight line perpendicular to the imaginary axis',
       'A parabola with axis parallel to the real axis',
       1
      ),(
       'The general solution to the differential equation $dy/dx + 2y = e^x$ is:',
       '$y = e^x + Ce^(-2x)$',
       '$y = (1/3)e^x + Ce^(-2x)$',
       '$y = -e^x + Ce^(-2x)$',
       '$y = (1/3)e^x + Ce^x$',
       2
      ),(
       'A particle moves randomly along a number line, starting at x = 0. At each step, it moves either left or right with equal probability. What is the probability of returning to the origin after exactly 4 steps?',
       '3/8',
       '1/4',
       '3/16',
       '4/16',
       1
      ),(
       'If A is a 3x3 matrix with eigenvalues 2, 3, and 5, which of these could be det(2A - I)?',
       '17',
       '119',
       '135',
       '89',
       3
      ),(
       'Find the locus of z if |z-3+4i|=5',
       'Circle centered at (3,4) with radius 5',
       'Circle centered at (-3,-4) with radius 5',
       'Circle centered at (3,-4) with radius 5',
       'Circle centered at (-3,4) with radius 5',
       3
      ),(
       'Solve $\\frac{dy}{dx} = 3y$',
       '$y = Ce^{3x}$',
       '$y = 3Ce^{x}$',
       '$y = Cx^3$',
       '$y = Ce^{x/3}$',
       1
      ),(
       'A particle moves along $\vec{r}(t) = t\hat{i} + t^2\hat{j}$. Find its velocity at t = 2.',
       '$\hat{i} + 4\hat{j}$',
       '$2\hat{i} + 4\hat{j}$',
       '$\hat{i} + 2\hat{j}$',
       '$2\hat{i} + 2\hat{j}$',
       1
      ),(
       'Evaluate $\\int (2x^3 + 3x^2)dx$',
       '$12x^4 + x^3 + C$',
       '$12x^4 + x^3$',
       '$12x^4 + x^3 - C$',
       '$x^4 + 3x^2 + C$',
       1
      ),(
       'Find the remainder when  $7^{10}$ is divided by 5.',
       '2',
       '3',
       '4',
       '1',
       3
      ),(
       'Determine\ if\ a_n = \frac{1}{n}\ \text{converges}.',
       'Converges to 0',
       'Converges to 1',
       'Diverges',
       'Converges to $\infty$',
       1
      ),(
       'A rectangle has perimeter 20. Maximize its area. What are its sides?',
       '5 x 5',
       '4 x 6',
       '2 x 8',
       '10 x 0',
       1
      ),(
       'Two dice are rolled. Probability sum = 8?',
       '5/36',
       '1/8',
       '7/36',
       '1/6',
       1
      ),(
       'If $A = \begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix}$, compute $\det(A)$.',
       '-2',
       '2',
       '-1',
       '1',
       1
      ),(
       'A cube has side 4. Find its space diagonal.',
       '4√2',
       '4√3',
       '8',
       '16',
       2
      ),(
       'A cylinder is inscribed in a sphere of radius r. Find ratio of height to radius for max volume.',
       '1:1',
       '2:3',
       '1:2',
       '√2:1',
       4
      ),(
       'Two cards drawn from a deck. Probability both are aces?',
       '1/221',
       '1/169',
       '1/132',
       '1/663',
       1
      ),(
       'Find the volume of a cube with side 5.',
       '25',
       '50',
       '125',
       '100',
       3
      ),(
       'Three coins tossed. Probability exactly 2 heads?',
       '1/2',
       '3/8',
       '1/4',
       '1/8',
       2
      ),(
       'Distance between (1,2,3) and (4,6,8)?',
       '5',
       '√50',
       '√35',
       '7',
       2
      ),(
       'Find $13^{100}$ (mod 7) ',
       '1',
       '3',
       '4',
       '6',
       1
      ),(
       'If $a \equiv 3 \pmod{5}$ and $b \equiv 4 \pmod{5}$, find $a + b \pmod{5}$.',
       '2',
       '1',
       '0',
       '4',
       1
      )
   ) AS t(question_text, ans1, ans2, ans3, ans4, correct_which)
 LOOP
   INSERT INTO questions (question_set_id, question_text, topic_id)
   VALUES (p_set_id, r.question_text, p_topic_id)
   RETURNING question_id INTO qid;


   INSERT INTO answers (question_id, answer_text, is_correct) VALUES
     (qid, r.ans1, r.correct_which = 1),
     (qid, r.ans2, r.correct_which = 2),
     (qid, r.ans3, r.correct_which = 3),
     (qid, r.ans4, r.correct_which = 4);
 END LOOP;
END $$;
