import type { Question } from '../../types/question.ts';
import { questions2013 } from './2013.ts';
import { questions2014 } from './2014.ts';
import { questions2015 } from './2015.ts';

export { questions2013, questions2014, questions2015 };

export const questions: Question[] = [...questions2013, ...questions2014, ...questions2015];
