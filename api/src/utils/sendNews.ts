import { sendDailyNotification } from "./fcm";

sendDailyNotification().then(() => process.exit(0));
