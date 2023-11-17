-- CreateTable
CREATE TABLE "Url" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "url" TEXT NOT NULL
);

-- CreateIndex
CREATE UNIQUE INDEX "Url_url_key" ON "Url"("url");
