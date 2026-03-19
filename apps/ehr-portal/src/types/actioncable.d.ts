declare module "@rails/actioncable" {
  export interface Subscription {
    unsubscribe(): void
  }

  export interface Consumer {
    subscriptions: {
      create(
        channel: Record<string, unknown>,
        callbacks?: {
          connected?(): void
          disconnected?(): void
          received?(data: unknown): void
        }
      ): Subscription
    }
    disconnect(): void
  }

  export function createConsumer(url?: string): Consumer
}
