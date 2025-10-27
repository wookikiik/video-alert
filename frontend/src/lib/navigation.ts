/**
 * NavSubItem 인터페이스
 * 계층적 네비게이션의 하위 항목 구조를 정의합니다.
 */
export interface NavSubItem {
  /** 하위 메뉴 항목의 제목 */
  title: string;
  /** 하위 메뉴 항목의 URL 경로 */
  url: string;
  /** 현재 활성화된 항목 여부 (선택사항) */
  isActive?: boolean;
}

/**
 * NavMainItem 인터페이스
 * 계층적 네비게이션의 상위 항목 구조를 정의합니다.
 */
export interface NavMainItem {
  /** 상위 메뉴 항목의 제목 */
  title: string;
  /** 상위 메뉴 항목의 URL 경로 */
  url: string;
  /** 하위 메뉴 항목 목록 (선택사항) */
  items?: NavSubItem[];
}

/**
 * NavigationData 인터페이스
 * 전체 계층적 네비게이션 구조를 정의합니다.
 */
export interface NavigationData {
  /** 상위 네비게이션 항목 목록 */
  navMain: NavMainItem[];
}

/**
 * 계층적 네비게이션 데이터
 * Sidebar와 Breadcrumb에서 공통으로 사용됩니다.
 */
export const hierarchicalNavigationData: NavigationData = {
  navMain: [
    {
      title: "Admin",
      url: "/admin/system-variables",
      items: [
        {
          title: "System Variables",
          url: "/admin/system-variables",
          isActive: true,
        },
      ],
    },
  ],
};
