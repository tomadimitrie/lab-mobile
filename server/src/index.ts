import express, { Request } from "express";
import { PrismaClient } from "@prisma/client";
import bodyParser from "body-parser";
import multer from "multer";
import path from "path";
import expressWs from "express-ws";

const app = express();
app.use("/static", express.static(path.join(__dirname, "..", "uploads/")));
app.use(bodyParser.json());

expressWs(app);

let ws: any;

const upload = multer({
  limits: {
    fieldSize: 25 * 1024 * 1024,
  },
  storage: multer.diskStorage({
    destination: (req, file, cb) => {
      cb(null, path.join(__dirname, "..", "uploads/"));
    },
    filename: (req, file, cb) => {
      cb(null, Date.now() + ".png");
    },
  }),
});

const prisma = new PrismaClient();

app.get("/", async (req, res) => {
  const events = await prisma.event.findMany();
  res.json(events);
});

type PostRequest = {
  name: string;
  date: string;
  location: string;
  tags: string[];
  username: string;
};

app.post("/", upload.single("image"), async (req, res) => {
  const {
    name,
    date,
    location,
    tags,
    username: createdBy,
  } = req.body as PostRequest;
  const data = {
    name,
    date,
    location,
    tags,
    createdBy,
    imageUrl: req.file?.filename!,
  };
  const event = await prisma.event.create({
    data,
  });
  ws.send(
    JSON.stringify({
      action: "create",
      data: event,
    })
  );
  res.status(200).end();
});

app.put("/:id", upload.single("image"), async (req, res) => {
  const id = req.params.id;
  const { name, date, location, tags } = req.body as PostRequest;
  const data = {
    name,
    date,
    location,
    tags,
    imageUrl: req.file?.filename!,
  };
  const event = await prisma.event.update({
    where: {
      id,
    },
    data,
  });
  ws.send(
    JSON.stringify({
      action: "update",
      data: event,
    })
  );
  res.status(200).end();
});

app.delete("/:id", async (req, res) => {
  const id = req.params.id;
  const event = await prisma.event.findUnique({
    where: {
      id,
    },
  });
  const username = req.query.username;
  if (event!.createdBy !== username) {
    res.status(400).end();
  }
  await prisma.event.delete({
    where: {
      id,
    },
  });
  ws.send(
    JSON.stringify({
      action: "delete",
      data: {
        id,
      },
    })
  );
  res.status(200).end();
});

app.put("/favorite/:id", async (req, res) => {
  const id = req.params.id;
  const username = req.body.username;
  await prisma.event.update({
    where: {
      id,
    },
    data: {
      favoritedBy: {
        push: username,
      },
    },
  });
  ws.send(
    JSON.stringify({
      action: "favorite",
      data: {
        id,
      },
    })
  );
  res.status(200).end();
});

app.put("/unfavorite/:id", async (req, res) => {
  const id = req.params.id;
  const username = req.body.username;
  const event = await prisma.event.findUnique({
    where: {
      id,
    },
  });
  await prisma.event.update({
    where: {
      id,
    },
    data: {
      favoritedBy: {
        set: event!.favoritedBy.filter((user) => user != username),
      },
    },
  });
  ws.send(
    JSON.stringify({
      action: "unfavorite",
      data: {
        id,
      },
    })
  );
  res.status(200).end();
});

(app as any).ws("/socket", (socket: any, req: Request) => {
  ws = socket;
});

app.listen(3000, () => {});
