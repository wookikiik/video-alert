"use client";

import { usePathname } from "next/navigation";
import {
  Breadcrumb,
  BreadcrumbItem,
  BreadcrumbLink,
  BreadcrumbList,
  BreadcrumbPage,
  BreadcrumbSeparator,
} from "@/components/ui/breadcrumb";
import { hierarchicalNavigationData } from "@/lib/navigation";

interface BreadcrumbSegment {
  title: string;
  url: string;
  isCurrentPage: boolean;
}

/**
 * AppBreadcrumb 컴포넌트
 * 현재 페이지 경로에 따라 동적으로 Breadcrumb을 표시합니다.
 * 홈페이지('/')에서는 표시되지 않습니다.
 */
export function AppBreadcrumb() {
  const pathname = usePathname();

  // 홈페이지에서는 Breadcrumb을 표시하지 않음
  if (pathname === "/") {
    return null;
  }

  // 현재 경로에 해당하는 breadcrumb 경로 찾기
  const breadcrumbPath = findBreadcrumbPath(pathname);

  // 매칭되는 경로가 없으면 표시하지 않음
  if (breadcrumbPath.length === 0) {
    return null;
  }

  return (
    <Breadcrumb>
      <BreadcrumbList>
        {breadcrumbPath.map((segment, index) => (
          <div key={`${segment.url}-${index}`} className="contents">
            <BreadcrumbItem className={index === 0 ? "" : "hidden md:block"}>
              {segment.isCurrentPage ? (
                <BreadcrumbPage>{segment.title}</BreadcrumbPage>
              ) : (
                <BreadcrumbLink href={segment.url}>
                  {segment.title}
                </BreadcrumbLink>
              )}
            </BreadcrumbItem>
            {index < breadcrumbPath.length - 1 && (
              <BreadcrumbSeparator className="hidden md:block" />
            )}
          </div>
        ))}
      </BreadcrumbList>
    </Breadcrumb>
  );
}

/**
 * 현재 경로에 해당하는 Breadcrumb 경로를 찾습니다.
 * @param pathname - 현재 페이지 경로
 * @returns Breadcrumb 세그먼트 배열
 */
function findBreadcrumbPath(pathname: string): BreadcrumbSegment[] {
  const segments: BreadcrumbSegment[] = [];

  // hierarchicalNavigationData에서 현재 경로와 일치하는 항목 찾기
  for (const mainItem of hierarchicalNavigationData.navMain) {
    // 하위 항목이 있는 경우
    if (mainItem.items && mainItem.items.length > 0) {
      for (const subItem of mainItem.items) {
        if (subItem.url === pathname) {
          // 상위 항목 추가
          segments.push({
            title: mainItem.title,
            url: mainItem.url,
            isCurrentPage: false,
          });
          // 하위 항목 추가 (현재 페이지)
          segments.push({
            title: subItem.title,
            url: subItem.url,
            isCurrentPage: true,
          });
          return segments;
        }
      }
    }

    // 하위 항목이 없거나 매칭되지 않은 경우, 상위 항목 자체가 현재 경로인지 확인
    if (mainItem.url === pathname) {
      segments.push({
        title: mainItem.title,
        url: mainItem.url,
        isCurrentPage: true,
      });
      return segments;
    }
  }

  return segments;
}
