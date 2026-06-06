<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:s="http://www.sitemaps.org/schemas/sitemap/0.9"
  xmlns:xhtml="http://www.w3.org/1999/xhtml">
  <xsl:output method="html" encoding="UTF-8" indent="yes"/>
  <xsl:template match="/">
    <html lang="en">
    <head>
      <meta charset="UTF-8"/>
      <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
      <meta name="robots" content="noindex"/>
      <title>HorusQuest — XML Sitemap</title>
      <style>
        :root { --violet:#7C3AED; --sky:#38BDF8; }
        * { box-sizing:border-box; }
        body { margin:0; font-family:'Inter',system-ui,-apple-system,Segoe UI,Roboto,Arial,sans-serif; color:#1e293b; background:#f8fafc; }
        header { background:linear-gradient(135deg,var(--violet),var(--sky)); color:#fff; padding:1.75rem 1.25rem; }
        header h1 { margin:0; font-size:1.5rem; }
        header p { margin:.4rem 0 0; opacity:.95; font-size:.9rem; }
        main { max-width:1100px; margin:0 auto; padding:1.25rem; }
        table { width:100%; border-collapse:collapse; background:#fff; border:1px solid #e2e8f0; border-radius:10px; overflow:hidden; font-size:.875rem; }
        th, td { text-align:left; padding:.6rem .75rem; border-bottom:1px solid #eef2f7; }
        th { background:#f1f5f9; font-weight:600; text-transform:uppercase; font-size:.72rem; letter-spacing:.04em; color:#475569; }
        tr:last-child td { border-bottom:none; }
        tr:hover td { background:#faf5ff; }
        td.num, td.alt, td.pri { text-align:center; color:#64748b; white-space:nowrap; }
        a { color:var(--violet); text-decoration:none; word-break:break-all; }
        a:hover { text-decoration:underline; }
      </style>
    </head>
    <body>
      <header>
        <h1>HorusQuest — XML Sitemap</h1>
        <p>
          <xsl:value-of select="count(s:urlset/s:url)"/> URLs ·
          generated for search engines · this styled view is for humans, crawlers read the raw XML.
        </p>
      </header>
      <main>
        <table>
          <thead>
            <tr>
              <th>#</th>
              <th>URL</th>
              <th>Alt langs</th>
              <th>Last modified</th>
              <th>Priority</th>
            </tr>
          </thead>
          <tbody>
            <xsl:for-each select="s:urlset/s:url">
              <tr>
                <td class="num"><xsl:value-of select="position()"/></td>
                <td><a href="{s:loc}"><xsl:value-of select="s:loc"/></a></td>
                <td class="alt"><xsl:value-of select="count(xhtml:link)"/></td>
                <td><xsl:value-of select="s:lastmod"/></td>
                <td class="pri"><xsl:value-of select="s:priority"/></td>
              </tr>
            </xsl:for-each>
          </tbody>
        </table>
      </main>
    </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
