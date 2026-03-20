// apps/ehr-portal/src/app/(app)/providers/page.tsx

export const dynamic = "force-dynamic"

import { getGraphQLClient } from "@/lib/graphql"
import { gql } from "graphql-request"
import Link from "next/link"
import { Stethoscope, ChevronRight } from "lucide-react"

const query = gql`
  query {
    providers {
      id
      fullName
      npi
      clinicName
      specialty {
        id
        name
      }
    }
  }
`

type Provider = {
  id: string
  fullName: string
  npi: string
  clinicName: string | null
  specialty: { id: string; name: string } | null
}

export default async function ProvidersPage() {
  const graphql = await getGraphQLClient()
  const data = await graphql.request<{ providers: Provider[] }>(query)
  const providers = data.providers

  return (
    <div className="p-8">

      {/* Page header */}
      <div className="mb-8">
        <div className="flex items-center gap-3 mb-1">
          <Stethoscope className="w-6 h-6 text-blue-600" />
          <h1 className="text-2xl font-semibold text-slate-900">Providers</h1>
          <span className="inline-flex items-center rounded-full bg-blue-50 px-2.5 py-0.5 text-xs font-medium text-blue-700">
            {providers.length}
          </span>
        </div>
        <p className="text-sm text-slate-500">
          Physicians and care team members at Princeton-Plainsboro
        </p>
      </div>

      {/* Provider cards */}
      <div className="grid gap-3">
        {providers.map((provider) => (
          <Link
            key={provider.id}
            href={`/providers/${provider.id}`}
            className="group flex items-center justify-between rounded-xl bg-white border border-slate-200 px-5 py-4 shadow-sm hover:border-blue-300 hover:shadow-md transition-all"
          >
            <div className="flex items-center gap-4">
              {/* Initials avatar */}
              <div className="flex items-center justify-center w-10 h-10 rounded-full bg-blue-100 text-blue-700 font-semibold text-sm shrink-0">
                {provider.fullName.split(" ").map((n) => n[0]).join("").slice(0, 2)}
              </div>

              <div>
                <p className="font-medium text-slate-900 group-hover:text-blue-600 transition-colors">
                  {provider.fullName}
                </p>
                <div className="flex items-center gap-2 mt-0.5">
                  {provider.specialty && (
                    <span className="inline-flex items-center rounded-full bg-slate-100 px-2 py-0.5 text-xs font-medium text-slate-600">
                      {provider.specialty.name}
                    </span>
                  )}
                  {provider.clinicName && (
                    <span className="text-xs text-slate-400">{provider.clinicName}</span>
                  )}
                </div>
              </div>
            </div>

            <ChevronRight className="w-4 h-4 text-slate-400 group-hover:text-blue-500 transition-colors shrink-0" />
          </Link>
        ))}
      </div>
    </div>
  )
}
