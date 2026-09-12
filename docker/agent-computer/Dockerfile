FROM mcr.microsoft.com/playwright:v1.58.0-noble

RUN useradd --create-home --uid 10001 humane
COPY browser.mjs /opt/humane/browser.mjs
RUN chown humane:humane /opt/humane/browser.mjs

USER humane
