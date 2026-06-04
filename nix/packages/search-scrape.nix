{ ... }:

let
  mkSearchScrape =
    pkgs:
    let
      crawl4ai = pkgs.python3Packages.buildPythonPackage rec {
        pname = "crawl4ai";
        version = "0.6.2";
        format = "setuptools";

        src = pkgs.fetchPypi {
          inherit pname version;
          hash = "sha256-9SrO5TlQDsX8jtu306M3ihsm95AXpSEXvRBnOpCg9WI=";
        };

        nativeBuildInputs = with pkgs.python3Packages; [
          setuptools
        ];

        propagatedBuildInputs = with pkgs.python3Packages; [
          httpx
          beautifulsoup4
          lxml
          aiohttp
          aiofiles
          markdownify
          colorama
          pydantic
        ];

        doCheck = false;

        preBuild = ''
          export HOME="$TMPDIR"
        '';
      };

      pythonEnv = pkgs.python3.withPackages (ps: [
        crawl4ai
        ps.httpx
        ps.colorama
        ps.pydantic
      ]);

      searchScrapeScript = pkgs.writeScriptBin "search-scrape" ''
        #!${pythonEnv}/bin/python3
        """SearXNG search -> crawl4ai scrape -> markdown pipeline"""
        import sys
        import json
        import asyncio
        import os

        import httpx
        from crawl4ai import AsyncWebCrawler, CrawlerRunConfig

        SEARXNG_URL = os.environ.get("SEARXNG_URL", "http://127.0.0.1:8888")

        async def search(query: str, max_results: int = 5) -> list[dict]:
            async with httpx.AsyncClient() as client:
                resp = await client.get(
                    f"{SEARXNG_URL}/search",
                    params={"q": query, "format": "json"},
                    timeout=15.0,
                )
                data = resp.json()
                results = []
                for r in data.get("results", [])[:max_results]:
                    results.append({
                        "title": r.get("title", ""),
                        "url": r.get("url", ""),
                        "snippet": r.get("content", ""),
                    })
                return results

        async def scrape(url: str, max_chars: int = 5000) -> str:
            async with AsyncWebCrawler() as crawler:
                result = await crawler.arun(url=url, config=CrawlerRunConfig(
                    word_count_threshold=10,
                    exclude_external_links=True,
                ))
                return result.markdown[:max_chars]

        async def main():
            args = sys.argv[1:]
            if not args:
                print("Usage: search-scrape <query> [--no-scrape] [--scrape N]", file=sys.stderr)
                sys.exit(1)

            scrape_mode = True
            scrape_count = 3
            query_parts = []
            i = 0
            while i < len(args):
                if args[i] == "--no-scrape":
                    scrape_mode = False
                elif args[i] == "--scrape" and i + 1 < len(args):
                    scrape_count = int(args[i + 1])
                    i += 1
                else:
                    query_parts.append(args[i])
                i += 1

            query = " ".join(query_parts)
            results = await search(query, max_results=scrape_count)

            if not scrape_mode:
                for r in results:
                    print(f"## {r['title']}\n{r['snippet']}\n<{r['url']}>\n")
                return

            async def scrape_one(r: dict) -> str:
                try:
                    content = await scrape(r["url"])
                    return f"## {r['title']}\n**URL:** {r['url']}\n\n{content}"
                except Exception as e:
                    return f"## {r['title']}\n**URL:** {r['url']}\n*Scrape failed: {e}*\n\n{r['snippet']}"

            tasks = [scrape_one(r) for r in results]
            outputs = await asyncio.gather(*tasks)

            print(f"# Search: {query}\n")
            print("\n\n---\n".join(outputs))

        asyncio.run(main())
      '';
    in
    pkgs.symlinkJoin {
      name = "search-scrape";
      paths = [ searchScrapeScript ];
      meta = with pkgs.lib; {
        description = "SearXNG search + crawl4ai content extraction pipeline";
        license = licenses.mit;
        mainProgram = "search-scrape";
        platforms = platforms.linux;
      };
    };
in
{
  flake.overlays.search-scrape = final: _: {
    search-scrape = mkSearchScrape final;
  };

  perSystem =
    { pkgs, ... }:
    {
      packages.search-scrape = mkSearchScrape pkgs;
    };
}
