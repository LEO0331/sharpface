import type { MetadataRoute } from "next";
import { categoryNames, getTopics, questions } from "@/lib/questions";
import { siteUrl } from "@/lib/site";

export const dynamic = "force-static";

export default function sitemap(): MetadataRoute.Sitemap {
  const paths = [
    "/", "/questions/", "/topics/", "/practice/", "/about/",
    ...Object.keys(categoryNames).map((slug) => `/categories/${slug}/`),
    ...[...new Set(getTopics().map((t) => t.slug))].map((slug) => `/topics/${slug}/`),
    ...questions.map((q) => `/questions/${q.id}/`),
  ];
  return paths.map((path) => ({ url: `${siteUrl}${path}` }));
}
