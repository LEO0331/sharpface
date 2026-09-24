import type { PastExamSource } from '../../types/question.ts';

export const examFiles: Record<number, string> = {
  2013: 'CNA-2013-S1-Main.pdf',
  2014: 'CNA-2014-s1 (4) (1).pdf',
  2015: 'CNA-2015-s1-MAIN.pdf',
};

export const primaryExam = 'Primary Examination, Semester 1';

export function examSource(year: number, page: number): PastExamSource {
  return {
    type: 'past-exam',
    institution: 'University of Adelaide',
    course: 'Computer Networks and Applications',
    courseCode: 'COMPSCI 3001 / 7039',
    year,
    file: examFiles[year],
    page,
  };
}
