---
description: Scaffold a new blog post as a draft page bundle
---
Create a new draft blog post. Topic/title: $ARGUMENTS

1. Make a short kebab-case slug from the title (ask me if the title is ambiguous).
2. Run `./.bin/hugo new content/en/blog/<slug>/index.md`.
3. Fill the front matter per docs/content-guide.md (draft: true, description 140–160 chars,
   translationKey = slug, 2–4 tags from the allowed list; ask before adding a new tag).
4. Add a section outline (H2 headings + one-line notes on what goes in each). Don't write the post
   body; that's mine.
5. Tell me the preview URL from `make serve`.
